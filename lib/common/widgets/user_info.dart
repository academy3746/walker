import 'dart:io';
import 'package:android_id/android_id.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:fk_user_agent/fk_user_agent.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info/package_info.dart';

class UserInfo {
  /// Get App Version
  Future<String> getAppVersion() async {
    var version = "undefined";

    var packageInfo = await PackageInfo.fromPlatform();

    version = packageInfo.version;

    return version;
  }

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

  /// Get User Agent
  Future<String> getDevicePlatform() async {
    var platformVersion = "undefined";

    platformVersion = FkUserAgent.webViewUserAgent!;

    return platformVersion;
  }

  /// Generate App Scheme
  Future<String> getAppScheme() async {
    var scheme = "";

    var agent = await getDevicePlatform();

    var hyApp = "hyapp;";

    var appId = await getDeviceId();

    var version = await getAppVersion();

    scheme = "$agent ($hyApp boolub.com $appId $version)";

    return scheme;
  }
}
