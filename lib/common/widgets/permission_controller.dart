// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AccessPermission {
  bool hasPermission = false;

  Future<bool> initPermission(BuildContext context) async {
    final locationPermission = await Permission.location.request();

    final healthPermission = await Permission.activityRecognition.request();

    final locDenied =
        locationPermission.isDenied || locationPermission.isPermanentlyDenied;

    final healthDenied =
        healthPermission.isDenied || healthPermission.isPermanentlyDenied;

    if (!locDenied && !healthDenied) {
      hasPermission = true;

      print("Access to location data has submitted by user.");
      print("Access to health data has submitted by user.");

      return true;
    } else {
      print("Access to location data has denied by user.");
      print("Access to health data has denied by user.");

      if (context.mounted) {
        AlertDialog(
          title: const Text("위치 및 신체 활동 접근 권한을 허용해 주세요!"),
          content: const Text("권한을 수락 하기 위하여 설정 화면으로 이동하시겠습니까?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);

                openAppSettings();
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
      }

      return false;
    }
  }
}
