// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AccessPermissionHandler {
  final BuildContext context;

  AccessPermissionHandler(this.context);

  Future<void> requestPermission() async {
    PermissionStatus status = await Permission.manageExternalStorage.status;

    if (status.isGranted) {
      PermissionStatus result = await Permission.manageExternalStorage.request();

      if (result.isGranted) {
        print("Permission has submitted by user");
      } else {
        print("Permission has denied by user");
      }
    }
  }
}