// ignore_for_file: avoid_print

import 'package:health/health.dart';

class HealthInfo {
  int steps = 0;

  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

  var now = DateTime.now();

  var types = [HealthDataType.STEPS];

  Future<void> _setHealthPermission() async {
    bool requested = await health.requestAuthorization(types);

    List<HealthDataPoint> healthData = await health.getHealthDataFromTypes(
      now.subtract(const Duration(days: 1)),
      now,
      types,
    );

    types = [HealthDataType.STEPS];

    var permissions = [HealthDataAccess.READ_WRITE];

    await health.requestAuthorization(
      types,
      permissions: permissions,
    );
  }
}
