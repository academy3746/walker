import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';

class BackHandlerButton {
  BuildContext context;
  DateTime? lastPressed;
  String? mainUrl;
  WebViewController? controller;

  BackHandlerButton({
    required this.context,
    this.mainUrl,
    this.controller,
  });

  Future<bool> onWillPop() async {
    final now = DateTime.now();
    final bool interval = lastPressed == null ||
        now.difference(lastPressed!) > const Duration(seconds: 2);

    if (interval) {
      String? currentUrl = await controller?.currentUrl();

      if (currentUrl != null && currentUrl == mainUrl) {
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
    } else {
      if (context.mounted) {
        exit(0);
      }
    }

    return Future.value(true);
  }
}