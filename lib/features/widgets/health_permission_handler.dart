// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class AccessHealthPermissionHandler {
  final BuildContext context;

  AccessHealthPermissionHandler(this.context);
  
  Future<bool> requestHealthPermission() async {
    PermissionStatus status = await Permission.activityRecognition.status;
    
    if (status.isGranted) {
      print("Health Permission has submitted by user.");
      return true;
    } else if (status.isDenied) {
      PermissionStatus result = await Permission.activityRecognition.request();
      
      if (result.isGranted) {
        print("Health Permission has submitted by user.");
        return true;
      } else {
        print("Health Permission has denied by user.");
        return false;
      }
    } else if (status.isPermanentlyDenied) {
      print("Health permission has permanently denied by user.");

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Health Care 접근 권한을 허용해 주세요!"),
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