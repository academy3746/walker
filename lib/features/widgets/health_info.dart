// ignore_for_file: avoid_print

import 'package:health/health.dart';

class HealthInfo {
  int steps = 0;

  HealthFactory health = HealthFactory(useHealthConnectIfAvailable: true);

  var now = DateTime.now();

  var types = [HealthDataType.STEPS];
}
