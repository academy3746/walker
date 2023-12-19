// ignore_for_file: avoid_print

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AppVersionHandler {
  final BuildContext context;

  AppVersionHandler(this.context);

  Future<void> getAppVersionStatus() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;

    print("App Version: $version");

    /// Version Management (Manually)
    const String androidVersion = "1.0.0";
    const String iosVersion = "1.0.0";

    if ((Platform.isAndroid && version != androidVersion) ||
        (Platform.isIOS && version != iosVersion)) {
      _showUpdateDialog();
    }
  }

  Future<void> _showUpdateDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("앱 업데이트 안내"),
          content: const Text("최신 버전의 앱이 아닙니다.\n업데이트를 위해 마켓으로\n이동하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () async {
                if (Platform.isAndroid) {
                  final Uri playStore =
                      Uri.parse("market://details?id=kr.sogeum.walker");

                  if (await canLaunchUrl(playStore)) {
                    await launchUrl(playStore);
                  } else {
                    print("Wrong URL Request: $playStore");
                  }
                } else if (Platform.isIOS) {
                  final Uri appStore =
                      Uri.parse("https://apps.apple.com/app/부럽/id");

                  if (await canLaunchUrl(appStore)) {
                    await launchUrl(appStore);
                  } else {
                    print("Wrong URL Request: $appStore");
                  }

                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text("확인"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("취소"),
            ),
          ],
        );
      },
    );
  }
}
