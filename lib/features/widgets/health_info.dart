// ignore_for_file: avoid_print

import 'package:health/health.dart';

class HealthInfo {
  HealthFactory health = HealthFactory();

  List<HealthDataType> types = [HealthDataType.STEPS];

  var permissions = [HealthDataAccess.READ_WRITE];

  Future<bool> hasHealthDataAccess() async {
    return await health.hasPermissions(types, permissions: permissions) ??
        false;
  }

  Future<int> stepCount() async {
    int steps = 0;
    bool hasPermission = await hasHealthDataAccess();

    if (hasPermission) {
      try {
        List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
          DateTime.now().subtract(const Duration(days: 1)),
          DateTime.now(),
          types,
        );

        for (var data in healthData) {
          if (data.type == HealthDataType.STEPS) {
            var value = data.value as num;
            steps += value.toInt();
          }
        }

        print("걸음 수: $steps");
      } catch (e) {
        print(e);
      }
    } else {
      print("Steps count measurement has denied by user.");
    }

    return steps;
  }
}
