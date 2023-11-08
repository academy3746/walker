// ignore_for_file: avoid_print

import 'package:health/health.dart';

class HealthDataFetcher {
  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

  List<HealthDataType> types = [
    HealthDataType.STEPS,
  ];

  var permissions = [
    HealthDataAccess.READ_WRITE,
    HealthDataAccess.READ_WRITE,
  ];

  Future<bool> requestHealthDataAuthorization() async {
    return await health.requestAuthorization(
      types,
      permissions: permissions,
    );
  }

  Future<bool> hasHealthDataAccess() async {
    bool? hasAccess = await health.hasPermissions(types);
    return hasAccess ?? false;
  }


  Future<int> fetchSteps() async {
    int steps = 0;
    bool accessWasGranted = await hasHealthDataAccess();

    if (accessWasGranted) {
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
      } catch (e) {
        print(e);
      }
    } else {
      print("Access to health data has denied by the user.");
    }

    return steps;
  }
}
