// ignore_for_file: avoid_print

import 'package:permission_handler/permission_handler.dart';

class AccessHealthPermissionHandler {
  Future<bool> requestHealthPermission() async {
    PermissionStatus status = await Permission.activityRecognition.status;

    if (status.isGranted) {
      PermissionStatus result = await Permission.activityRecognition.request();

      if (result.isGranted) {
        print("Access to health data has submitted by user.");

        return true;
      } else {
        print("Access to health data has denied by user.");

        return false;
      }

    } else if (status.isDenied || status.isPermanentlyDenied) {
      print("Access to health data has denied by user.");

      openAppSettings();

      return false;
    }

    return false;
  }
}
