// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AccessLocationPermissionHandler {
  final BuildContext context;

  AccessLocationPermissionHandler(this.context);

  Future<bool> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.status;

    if (status.isGranted) {
      print("Location permission has already submitted.");

      return true;
    } else if (status.isDenied) {
      PermissionStatus result = await Permission.location.request();

      if (result.isGranted) {
        print("Location permission has submitted by user.");

        return true;
      } else {
        print("Location permission has denied by user.");

        return false;
      }
    } else if (status.isPermanentlyDenied) {
      print("Location permission has permanently denied by user");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("위치정보 접근 권한을 허용해 주세요!"),
            duration: Duration(seconds: 2),
          ),
        );
      }

      openAppSettings();

      return false;
    }

    return false;
  }
}
