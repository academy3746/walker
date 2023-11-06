// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AccessPermissionHandler {
  final BuildContext context;

  AccessPermissionHandler(this.context);

  Future<void> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.status;

    if (status.isGranted) {
      PermissionStatus result = await Permission.location.request();

      if (result.isGranted) {
        print("Location Permission has submitted by user");
      } else {
        print("Location Permission has denied by user");
      }
    }
  }
}