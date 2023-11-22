import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';

class BackHandlerButton {
  BuildContext context;
  DateTime? lastPressed;
  String? mainUrl;
  String? homeUrl;
  WebViewController? controller;
  bool isAppForeground = false;

  BackHandlerButton({
    required this.context,
    this.mainUrl,
    this.homeUrl,
    this.controller,
  });

  Future<bool> onWillPop() async {
    final now = DateTime.now();
    final bool interval = lastPressed == null ||
        now.difference(lastPressed!) > const Duration(seconds: 2);

    if (interval) {
      String? currentUrl = await controller?.currentUrl();

      if ((currentUrl != null && currentUrl == mainUrl) || (currentUrl != null && currentUrl == homeUrl)) {
        lastPressed = now;
        const snackBar = SnackBar(
          content: Text("뒤로가기 버튼을 한 번 더 누르면 앱이 종료됩니다!"),
          duration: Duration(seconds: 2),
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context)
            ..removeCurrentSnackBar()
            ..showSnackBar(snackBar);
          return Future.value(false);
        }
      } else {
        controller?.goBack();
        return Future.value(false);
      }
    } else if (isAppForeground) {
      return Future.value(false);
    }

    return Future.value(true);
  }
}