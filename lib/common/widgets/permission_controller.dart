// ignore_for_file: avoid_print

import 'package:permission_handler/permission_handler.dart';

class AccessPermission {
  bool hasPermission = false;

  Future<bool> initPermission() async {
    final locationPermission = await Permission.location.request();

    final healthPermission = await Permission.activityRecognition.request();

    final locDenied = locationPermission.isDenied || locationPermission.isPermanentlyDenied;

    final healthDenied = healthPermission.isDenied || healthPermission.isPermanentlyDenied;

    if (!locDenied && !healthDenied) {
      hasPermission = true;

      print("Access to location data has submitted by user.");
      print("Access to health data has submitted by user.");

      return true;
    } else {
      print("Access to location data has denied by user.");
      print("Access to health data has denied by user.");

      openAppSettings();

      return false;
    }
  }
}
