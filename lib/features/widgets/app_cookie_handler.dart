// ignore_for_file: avoid_print

import 'dart:io';

import 'package:webview_cookie_manager/webview_cookie_manager.dart';

class AppCookieHandler {
  final WebviewCookieManager _cookieManager = WebviewCookieManager();
  final String _cookieValue = "cookieValue";
  final String _domain;
  final String _cookieName = "cookieName";
  final String _url;

  AppCookieHandler(
    this._domain,
    this._url,
  );

  String get url => _url;

  String get cookieName => _cookieName;

  String get domain => _domain;

  String get cookieValue => _cookieValue;

  Future<void> setCookies(
    String cookieValue,
    String domain,
    String cookieName,
    String url,
  ) async {
    await _cookieManager.getCookies(url);

    await _cookieManager.setCookies(
      [
        Cookie(cookieName, cookieValue)
          ..domain = domain
          ..expires = DateTime.now().add(const Duration(days: 90))
          ..httpOnly = false
      ],
    );

    var printCookie = _cookieManager.getCookies(url);
    print("Debug Cookie Values: $printCookie");
  }
}
