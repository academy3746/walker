import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/foundation.dart';

class UserInfo {
  /// Get Unique Device ID
  Future<String> getDeviceId() async {
    var deviceIdentifier = "undefined";

    var deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      var androidInfo = const AndroidId();

      String? androidId = await androidInfo.getId();

      deviceIdentifier = androidId!;
    } else if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;

      deviceIdentifier = iosInfo.identifierForVendor!;
    } else if (kIsWeb) {
      var webInfo = await deviceInfo.webBrowserInfo;

      deviceIdentifier = webInfo.vendor! +
          webInfo.userAgent! +
          webInfo.hardwareConcurrency.toString();
    }

    return deviceIdentifier;
  }

  /// Get Device Platform
  Future<String> getDeviceOs() async {
    var devicePlatform = "undefined";

    if (Platform.isAndroid) {
      devicePlatform = "android";
    } else if (Platform.isIOS) {
      devicePlatform = "ios";
    } else if (kIsWeb) {
      devicePlatform = "web";
    }

    return devicePlatform;
  }

  /// Get User Agent
  Future<String> getDevicePlatform() async {
    var platformVersion = "undefined";

    platformVersion = FkUserAgent.userAgent!;

    return platformVersion;
  }
}
