// ignore_for_file: avoid_print

import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthInfo {
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

  int? steps;

  var types = [
    HealthDataType.STEPS,
    HealthDataType.DISTANCE_DELTA,
  ];

  var permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  var now = DateTime.now();

  Future<void> healthRequest() async {
    bool healthRequest = await health.requestAuthorization(
      types,
      permissions: permissions,
    );

    var midnight = DateTime(
      now.year,
      now.month,
      now.day,
    );

    if (healthRequest) {
      print("Access to collect health data has submitted by user.");

      try {
        steps = await health.getTotalStepsInInterval(midnight, now);

        print("$steps 걸음");
      } catch (e) {
        print("Health Data Fetch Error: $e");
      }
    } else {
      print("Access to collect health data has denied by user.");

      openAppSettings();
    }
  }
}
