// ignore_for_file: avoid_print, prefer_collection_literals

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/instance_manager.dart';
import 'package:walker/features/widgets/app_cookie_handler.dart';
import 'package:walker/features/widgets/app_version_check_handler.dart';
import 'package:walker/features/widgets/back_handler_button.dart';
import 'package:walker/features/widgets/fcm_controller.dart';
import 'package:walker/features/widgets/health_info.dart';
import 'package:walker/features/widgets/health_permission_handler.dart';
import 'package:walker/features/widgets/location_info.dart';
import 'package:walker/features/widgets/location_permission_handler.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static String routeName = "/main";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  /// Initialize WebView Controller
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();
  WebViewController? viewController;

  /// Initialize Main URL
  final String url = "https://boolub.com/?is_app=y";

  /// Import Back Action Handler
  BackHandlerButton? backHandlerButton;

  /// Import App Cookie Manager
  AppCookieHandler? cookieHandler;

  /// Initialize Loading Indicator
  bool isLoading = false;

  /// Import Location Info
  LocationInfo locationInfo = LocationInfo();

  /// Import FCM Controller
  final MsgController msgController = Get.put(MsgController());

  /// GPS Initialize
  Position? currentPosition;

  /// Initialize Address
  String? currentAddress;

  /// Import Health Data Info
  HealthInfo healthInfo = HealthInfo();

  /// Get Current Location Values
  Future<void> _determinePosition() async {
    try {
      Position position = await locationInfo.determinePermission();
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
    } catch (e) {
      print(e);
    }
  }

  /// Request Location Access Permission & Get Current Place
  Future<void> _requestAndDetermineLocation() async {
    AccessLocationPermissionHandler permissionHandler =
        AccessLocationPermissionHandler();
    bool hasLocPermission = await permissionHandler.requestLocationPermission();

    if (hasLocPermission) {
      print("위치정보 접근 권한이 허용되었습니다.");

      await _determinePosition();
      locationInfo.getStreaming();
      await _determineHealthData();
    } else {
      print("위치정보 접근 권한이 거부되었습니다.");
    }
  }

  /// Request Health Access Permission & Get Current Steps (~ing)
  Future<void> _determineHealthData() async {
    AccessHealthPermissionHandler permissionHandler =
        AccessHealthPermissionHandler();
    bool hasPermission = await permissionHandler.requestHealthPermission();

    if (hasPermission) {
      print("신체 활동 접근 권한이 허용되었습니다.");
    } else {
      print("신체 활동 접근 권한이 거부되었습니다.");
    }
  }

  Future<String?> _getPushToken() async {
    return await msgController.getToken();
  }

  @override
  void initState() {
    super.initState();

    /// Improve Android Performance
    if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();

    /// Initialize User Token
    _getPushToken();

    /// Exit Application with double touch
    _controller.future.then(
      (WebViewController webViewController) {
        viewController = webViewController;
        backHandlerButton = BackHandlerButton(
          context: context,
          controller: webViewController,
          mainUrl: url,
        );
      },
    );

    /// Initialize Cookie Settings
    cookieHandler = AppCookieHandler(url, url);

    /// App Version Handling (Manually)
    AppVersionHandler appVersionHandler = AppVersionHandler(context);
    appVersionHandler.getAppVersionStatus();

    _requestAndDetermineLocation();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (backHandlerButton != null) {
          return backHandlerButton!.onWillPop();
        }
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SizedBox(
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
                          if (url.contains(url) && viewController != null) {
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
                      zoomEnabled: true,
                      gestureRecognizers: Set()
                        ..add(
                          Factory<EagerGestureRecognizer>(
                            () => EagerGestureRecognizer(),
                          ),
                        ),
                      gestureNavigationEnabled: true,
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
      ),
    );
  }
}
