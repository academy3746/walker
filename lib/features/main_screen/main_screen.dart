// ignore_for_file: avoid_print, prefer_collection_literals, deprecated_member_use
import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tosspayments_widget_sdk_flutter/model/tosspayments_url.dart';
import 'package:walker/common/widgets/app_cookie_handler.dart';
import 'package:walker/common/widgets/app_version_check_handler.dart';
import 'package:walker/common/widgets/back_handler_button.dart';
import 'package:walker/common/widgets/fcm_controller.dart';
import 'package:walker/common/widgets/location_info.dart';
import 'package:walker/common/widgets/pedometer_controller.dart';
import 'package:walker/common/widgets/permission_controller.dart';
import 'package:walker/common/widgets/web_communication.dart';
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

  /// Request Push Permission & Get Unique Token Value from Firebase Server
  MsgController msgController = Get.put(MsgController());

  /// Import WebServerCommunication
  WebServerCommunication? communication;

  /// Initialize Pedometer
  late Stream<StepCount> _stepCountStream;

  late Stream<PedestrianStatus> _pedestrianStatusStream;

  String _status = "";

  String _steps = "0";

  int _lastTotalSteps = 0;

  int _lastUpdateDate = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

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

    /// Web Server Communication
    communication = WebServerCommunication(
      steps: _steps,
      currentPosition: currentPosition,
      currentAddress: currentAddress,
    );
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

        String? countryCode = await locationInfo.getCountryCode(position);

        locationInfo.lastPosition = position;

        locationInfo.lastCountryCode = countryCode;

        String address = await locationInfo.getCurrentAddress(
          position.latitude,
          position.longitude,
        );

        setState(() {
          currentPosition = position;

          currentAddress = address;

          print("현재 위치 값: $currentPosition");
          print("현재 주소: $currentAddress");
        });

        await locationInfo.getStreaming();
        //await locationInfo.debugStreaming();

        /// Get User Steps Count
        await _loadLastTotalSteps().then((_) => _pedometerHandler());
      } catch (e) {
        print(e);
      }
    } else {
      print("위치정보 접근 권한이 거부되었습니다.");
      print("신체 활동 접근 권한이 거부되었습니다.");
    }
  }

  /// Update Steps Count
  void _onStepCountUpdate(String newTotalStep) {
    DateTime nowDate = DateTime.now();

    DateTime midnight = DateTime(
      nowDate.year,
      nowDate.month,
      nowDate.day,
    );

    int newStepCount = int.parse(newTotalStep);

    if (nowDate.isAfter(midnight)) {
      int dailySteps = newStepCount - _lastTotalSteps;

      setState(() {
        _steps = dailySteps.toString();
      });

      if (dailySteps >= 10000) {
        msgController.sendInternalPush(
          "축하드립니다",
          "🏃‍♀️ 오늘 하루 총 $_steps걸음 걸으셨네요!",
        );
      }
    } else {
      _lastTotalSteps = newStepCount;

      _lastUpdateDate = nowDate.millisecondsSinceEpoch;

      setState(() {
        _steps = "0";
      });

      _saveLastTotalSteps();
    }
  }

  /// Update Physical Movement
  void _onPedestrianStatusUpdate(String newStatus) {
    setState(() {
      _status = newStatus;
    });
  }

  /// Handling User Steps Count
  void _pedometerHandler() {
    _loadLastTotalSteps();

    _stepCountStream = Pedometer.stepCountStream;

    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;

    PedometerController pedometerController = PedometerController(
      stepCountStream: _stepCountStream,
      pedestrianStatusStream: _pedestrianStatusStream,
      status: _status,
      steps: _steps,
      onStepCountUpdate: _onStepCountUpdate,
      onPedestrianStatusUpdate: _onPedestrianStatusUpdate,
    );

    pedometerController.initPlatformState(context);
  }

  /// Save Daily Steps Count
  Future<void> _saveLastTotalSteps() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(
      "lastTotalSteps",
      _lastTotalSteps,
    );

    await prefs.setInt(
      "lastUpdateDate",
      _lastUpdateDate,
    );
  }

  /// Load Daily Steps Count
  Future<void> _loadLastTotalSteps() async {
    final prefs = await SharedPreferences.getInstance();

    int lastSavedDate =
        prefs.getInt("lastUpdateDate") ?? DateTime.now().millisecondsSinceEpoch;

    DateTime lastSavedDateTime =
        DateTime.fromMillisecondsSinceEpoch(lastSavedDate);

    DateTime now = DateTime.now();

    DateTime lastMidnight = DateTime(
      now.year,
      now.month,
      now.day,
    );

    if (lastSavedDateTime.isBefore(lastMidnight)) {
      _lastTotalSteps = 0;
    } else {
      _lastTotalSteps = prefs.getInt("lastTotalSteps") ?? 0;
    }

    _lastUpdateDate = now.millisecondsSinceEpoch;
  }

  /// 백그라운드에서 App Process 유지
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      print("앱이 포그라운드에서 실행중입니다.");
    } else if (state == AppLifecycleState.paused) {
      print("앱이 백그라운드에서 실행중입니다.");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                  ? "[$_steps걸음] 걷고 계시네요!"
                  : "[$_steps걸음] 조금만 더 걸어 볼까요?",
              style: const TextStyle(
                color: Colors.black,
                fontSize: Sizes.size16,
              ),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
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
                        print("현재 페이지 주소: $url");
                        setState(() {
                          isLoading = true;
                        });
                      },
                      onPageFinished: (String url) async {
                        setState(() {
                          isLoading = false;
                        });

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
                      },
                      onWebResourceError: (error) {
                        print("Error Code: ${error.errorCode}");
                        print("RESOURCE ERROR Error Type ${error.errorType}");
                        print("RESOURCE ERROR Failing URL ${error.domain}");
                        print("Error Description: ${error.description}");
                      },
                      navigationDelegate: (request) async {
                        /// In App PG Payment Process
                        final appScheme = ConvertUrl(request.url);

                        if (appScheme.isAppLink()) {
                          appScheme.launchApp();

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
    );
  }
}
