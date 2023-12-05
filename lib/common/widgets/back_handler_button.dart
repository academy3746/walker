import 'package:flutter/material.dart';
import 'package:flutter_webview_pro/webview_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:walker/constants/sizes.dart';

class BackHandlerButton {
  BuildContext context;

  DateTime? lastPressed;

  String? mainUrl;

  String? homeUrl;

  WebViewController? controller;

  BackHandlerButton({
    required this.context,
    this.mainUrl,
    this.homeUrl,
    this.controller,
  });

  Future<bool> onWillPop() async {
    String? currentUrl = await controller?.currentUrl();

    DateTime now = DateTime.now();

    if (lastPressed == null ||
        now.difference(lastPressed!) > const Duration(seconds: 3)) {
      if (currentUrl == mainUrl || currentUrl == homeUrl) {
        lastPressed = now;

        if (context.mounted) {
          Fluttertoast.showToast(
            msg: "'뒤로' 버튼을 한번 더 누르면 앱이 종료됩니다.",
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Theme.of(context).primaryColor,
            fontSize: Sizes.size20,
            toastLength: Toast.LENGTH_SHORT,
          );
        }

        return false;
      } else {
        controller?.goBack();

        return false;
      }
    }

    return true;
  }
}
