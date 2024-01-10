// ignore_for_file: avoid_print, prefer_collection_literals, deprecated_member_use
import 'dart:async';
import 'dart:io';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:package_info/package_info.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tosspayments_widget_sdk_flutter/model/tosspayments_url.dart';
import 'package:walker/common/widgets/app_cookie_handler.dart';
import 'package:walker/common/widgets/app_version_check_handler.dart';
import 'package:walker/common/widgets/back_handler_button.dart';
import 'package:walker/common/widgets/client_info_comm.dart';
import 'package:walker/common/widgets/fcm_controller.dart';
import 'package:walker/common/widgets/location_comm.dart';
import 'package:walker/common/widgets/location_info.dart';
import 'package:walker/common/widgets/pedometer_controller.dart';
import 'package:walker/common/widgets/permission_controller.dart';
import 'package:walker/common/widgets/steps_comm.dart';
import 'package:walker/common/widgets/user_info.dart';
import 'package:walker/constants/gaps.dart';
import 'package:walker/constants/sizes.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static String routeName = "/main";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  /// Initialize WebView Controller
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  WebViewController? viewController;

  /// Initialize App URL
  final String url = "https://boolub.com/?is_app=y";

  /// Initialize Home URL
  final String homeUrl = "https://boolub.com/";

  /// Import Back Action Handler
  BackHandlerButton? backHandlerButton;

  /// Import App Cookie Manager
  AppCookieHandler? cookieHandler;

  /// Initialize Loading Indicator
  bool isLoading = false;

  /// Import Location Info
  LocationInfo locationInfo = LocationInfo();

  /// GPS Initialize
  Position? currentPosition;

  /// Initialize Address
  String? currentAddress;

  /// Initialize Country Code
  String? currentCountryCode;

  /// Initialize Country Name
  String? currentCountryName;

  /// Request Push Permission & Get Unique Token Value from Firebase Server
  MsgController msgController = Get.put(MsgController());

  /// Initialize Pedometer
  late PedometerController pedometerController;
  String _status = "";
  int _steps = 0;
  int _currentSteps = 0;
  int _savedSteps = 0;
  int _nowWalking = 0;
  int _initialSteps = 0;
  int _newSteps = 0;

  /// Get Unique User Information
  UserInfo userInfo = UserInfo();

  /// Initialize Home Button
  bool showFloatingActionButton = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await FkUserAgent.init();

      userInfo.getDevicePlatform();
    });

    /// Improve Android Performance
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    /// Exit Application with double touch
    _controller.future.then(
      (WebViewController webViewController) {
        viewController = webViewController;
        backHandlerButton = BackHandlerButton(
          context: context,
          controller: webViewController,
          mainUrl: url,
          homeUrl: homeUrl,
        );
      },
    );

    /// Initialize Cookie Settings
    cookieHandler = AppCookieHandler(homeUrl, url);

    /// App Version Handling (Manually)
    AppVersionHandler appVersionHandler = AppVersionHandler(context);

    appVersionHandler.getAppVersionStatus();

    /// Get User Data
    _fetchUserData();

    /// Get Today Steps Count
    pedometerController = PedometerController(
      stepCountStream: Pedometer.stepCountStream,
      pedestrianStatusStream: Pedometer.pedestrianStatusStream,
      status: _status,
      currentSteps: _steps,
      onStepCountUpdate: _onStepCountUpdate,
      onPedestrianStatusUpdate: _onPedestrianStatusUpdate,
    );
  }

  /// Direct to Home URL
  void _loadHomeUrl() {
    viewController?.loadUrl(url);
  }

  /// Request Associated Permission & Get Info
  Future<void> _fetchUserData() async {
    AccessPermission permissionHandler = AccessPermission();

    bool hasPermission = await permissionHandler.initPermission();

    if (hasPermission) {
      print("위치정보 접근 권한이 허용되었습니다.");
      print("신체 활동 접근 권한이 허용되었습니다.");

      try {
        Position position = await locationInfo.determinePermission();

        currentCountryCode = await locationInfo.getCountryCode(position);

        locationInfo.lastPosition = position;

        locationInfo.lastCountryCode = currentCountryCode;

        String address = await locationInfo.getCurrentAddress(
          position.latitude,
          position.longitude,
        );

        String countryName = await locationInfo.getCountryName(
          position.latitude,
          position.longitude,
        );

        setState(() {
          currentPosition = position;

          currentAddress = address;

          currentCountryName = countryName;

          print("현재 위치 값: $currentPosition");
          print("현재 위치한 국가 코드: $currentCountryCode");
          print("현재 위치한 국가명: $currentCountryName");
          print("현재 위치한 도시: $currentAddress");
        });

        await locationInfo.getStreaming();
        //await locationInfo.debugStreaming();

        /// Get User Steps Count
        await _initPedometer();
      } catch (e) {
        print(e);
      }
    } else {
      print("위치정보 접근 권한이 거부되었습니다.");
      print("신체 활동 접근 권한이 거부되었습니다.");
    }
  }

  /// Load Daily Steps Count
  Future<void> _initPedometer() async {
    await pedometerController.initPlatformState(context);

    await _sendClientInfoToServer();

    await _sendLocationInfoToWebServer();

    await _achieveDailySteps();
  }

  Future<void> _sendClientInfoToServer() async {
    String os = await userInfo.getDeviceOs();
    String userAgent = await userInfo.getDevicePlatform();
    String appId = await userInfo.getDeviceId();

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var appVersion = packageInfo.version;

    String? token = await msgController.getToken();

    ClientInfoCommunication infoComm = ClientInfoCommunication(
      os: os,
      userAgent: userAgent,
      appId: appId,
      appVersion: appVersion,
      token: token,
    );

    await infoComm.toJson({
      "au_os": os,
      "au_user_agent": userAgent,
      "au_app_id": appId,
      "au_app_ver": appVersion,
      "au_push_token": token,
    });
  }

  /// Update Steps Count
  Future<void> _onStepCountUpdate(int streamingSteps) async {
    _currentSteps = streamingSteps;

    setState(() {
      _steps = _currentSteps;
    });

    await _sendStepsToWebServer(_steps);
  }

  /// Update Physical Movement
  void _onPedestrianStatusUpdate(String newStatus) {
    setState(() {
      _status = newStatus;
    });
  }

  /// 위치 정보 전송
  Future<void> _sendLocationInfoToWebServer() async {
    var now = DateTime.now();
    var dateFormat = DateFormat("yyyy-MM-dd");
    var timeFormat = DateFormat("HH:mm:ss");
    var date = dateFormat.format(now);
    var time = timeFormat.format(now);

    LocationCommunication locationComm = LocationCommunication(
      countryName: currentCountryName,
      cityName: currentAddress,
      lat: currentPosition!.latitude.toString(),
      lng: currentPosition!.longitude.toString(),
      date: date,
      time: time,
    );

    await locationComm.toJson({
      "countryName": currentCountryName,
      "cityName": currentAddress,
      "lat": currentPosition!.latitude.toString(),
      "lng": currentPosition!.longitude.toString(),
      "date": date,
      "time": time,
    });
  }

  /// 걸음 수 전송 (작업중)
  Future<void> _sendStepsToWebServer(int steps) async {
    var now = DateTime.now();
    var dateFormat = DateFormat("yyyy-MM-dd");
    var date = dateFormat.format(now);

    final prefs = await SharedPreferences.getInstance();

    _savedSteps = prefs.getInt("savedSteps") ?? 0;
    _initialSteps = prefs.getInt("initialSteps") ?? 0;
    _newSteps = prefs.getInt("newSteps") ?? 0;

    StepsCommunication stepsComm = StepsCommunication(
      steps: steps,
      date: date,
    );

    if (_initialSteps != 0) {
      if (_savedSteps == 0) {
        setState(() {
          _nowWalking = steps - _initialSteps;
        });

        await prefs.setInt("dailySteps", _nowWalking);

        await stepsComm.toJson({
          "steps": _nowWalking,
          "date": date,
        });
      } else {
        setState(() {
          _nowWalking = steps - _savedSteps;
        });

        await prefs.setInt("dailySteps", _nowWalking);

        await stepsComm.toJson({
          "steps": _nowWalking,
          "date": date,
        });
      }
    } else {
      setState(() {
        _nowWalking = _newSteps;
      });

      await prefs.setInt("dailySteps", _nowWalking);

      await stepsComm.toJson({
        "steps": _nowWalking,
        "date": date,
      });
    }
  }

  /// 1만 걸음 달성 이벤트
  Future<void> _achieveDailySteps() async {
    var now = DateTime.now();

    var midnight = DateTime(
      now.year,
      now.month,
      now.day + 1,
    );

    final prefs = await SharedPreferences.getInstance();

    var dailySteps = prefs.getInt("dailySteps") ?? 0;

    if (now.isAfter(midnight)) {
      if (dailySteps >= 10000) {
        await msgController.sendInternalPush(
          "축하드려요!",
          "🏃‍♀️ 오늘 하루만 총 $dailySteps 걸음 걸으셨어요! 💕",
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  /// 백그라운드에서 App Process 유지
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      print("앱이 포그라운드에서 실행중입니다.");
    } else {
      print("앱이 백그라운드에서 실행중입니다.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: kDebugMode
          ? AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Row(
                children: [
                  const Icon(
                    Icons.directions_walk_rounded,
                    size: Sizes.size20,
                    color: Colors.black,
                  ),
                  Gaps.h5,
                  Text(
                    _status == "walking"
                        ? "[$_nowWalking걸음] 걷고 계시네요!"
                        : "[$_nowWalking걸음] 조금만 더 걸어 볼까요?",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: Sizes.size16,
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: Stack(
        children: [
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return WillPopScope(
                onWillPop: () async {
                  if (backHandlerButton != null) {
                    return backHandlerButton!.onWillPop();
                  }
                  return false;
                },
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: SafeArea(
                    child: WebView(
                      initialUrl: url,
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated:
                          (WebViewController webViewController) async {
                        _controller.complete(webViewController);
                        viewController = webViewController;

                        /// Get Cookie Statement
                        await cookieHandler?.setCookies(
                          cookieHandler!.cookieValue,
                          cookieHandler!.domain,
                          cookieHandler!.cookieName,
                          cookieHandler!.url,
                        );
                      },
                      onPageStarted: (String url) async {
                        setState(() {
                          isLoading = true;
                        });

                        print("현재 페이지 주소: $url");
                      },
                      onPageFinished: (String url) async {
                        setState(() {
                          isLoading = false;
                        });

                        /// Soft Keyboard hide TextField on Android
                        if (Platform.isAndroid) {
                          if (url.contains(homeUrl) && viewController != null) {
                            await viewController!.runJavascript("""
                              (function() {
                              function scrollToFocusedInput(event) {
                                const focusedElement = document.activeElement;
                                if (focusedElement.tagName.toLowerCase() === 'input' || focusedElement.tagName.toLowerCase() === 'textarea') {
                                  setTimeout(() => {
                                    focusedElement.scrollIntoView({ behavior: 'smooth', block: 'center' });
                                  }, 500);
                                }
                              }
                              document.addEventListener('focus', scrollToFocusedInput, true);
                            })();
                            """);
                          }
                        }

                        /// 외부 URL 처리
                        if (!url.startsWith(homeUrl)) {
                          setState(() {
                            showFloatingActionButton = true;
                          });
                        } else {
                          setState(() {
                            showFloatingActionButton = false;
                          });
                        }
                      },
                      onWebResourceError: (error) {
                        print("Error Code: ${error.errorCode}");
                        print("RESOURCE ERROR Error Type ${error.errorType}");
                        print("RESOURCE ERROR Failing URL ${error.domain}");
                        print("Error Description: ${error.description}");
                      },
                      navigationDelegate: (request) async {
                        final appScheme = ConvertUrl(request.url);

                        /// Toss Payments
                        if (appScheme.isAppLink()) {
                          try {
                            await appScheme.launchApp();
                          } on Error catch (e) {
                            print("Fail to start Toss Payments: $e");
                          }

                          return NavigationDecision.prevent;
                        }

                        return NavigationDecision.navigate;
                      },
                      zoomEnabled: false,
                      gestureRecognizers: Set()
                        ..add(
                          Factory<EagerGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                          ),
                        ),
                      gestureNavigationEnabled: true,
                    ),
                  ),
                ),
              );
            },
          ),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator.adaptive(),
                )
              : Container(),
        ],
      ),
      floatingActionButton: showFloatingActionButton
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              onPressed: _loadHomeUrl,
              child: const FaIcon(
                FontAwesomeIcons.house,
                size: Sizes.size26,
              ),
            )
          : null,
    );
  }
}
