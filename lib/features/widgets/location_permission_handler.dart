// ignore_for_file: avoid_print

import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class AccessLocationPermissionHandler {
  Future<bool> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.status;

    if (status.isGranted) {
      print("Access to location data has already submitted.");

      return true;
    } else if (status.isDenied) {
      PermissionStatus result = await Permission.location.request();

      if (result.isGranted) {
        print("Access to location data has submitted by user.");

        if (Platform.isAndroid) {
          openAppSettings();
        }

        return true;
      } else {
        print("Access to location data has denied by user.");

        openAppSettings();

        return false;
      }
    } else if (status.isPermanentlyDenied) {
      print("Location permission has permanently denied by user.");

      openAppSettings();

      return false;
    }

    return false;
  }
}
