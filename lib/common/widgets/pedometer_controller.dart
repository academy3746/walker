// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

class PedometerController {
  Stream<StepCount> stepCountStream;

  Stream<PedestrianStatus> pedestrianStatusStream;

  String status;

  String steps;

  final Function(String) onStepCountUpdate;

  final Function(String) onPedestrianStatusUpdate;

  PedometerController({
    required this.stepCountStream,
    required this.pedestrianStatusStream,
    required this.status,
    required this.steps,
    required this.onStepCountUpdate,
    required this.onPedestrianStatusUpdate,
  });

  void _onStepCount(StepCount event) {
    print("걸음수: $event");

    steps = event.steps.toString();

    onStepCountUpdate(steps);
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    print("운동 상태: $event");

    status = event.status;

    onPedestrianStatusUpdate(status);
  }

  void _onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');

    status = "운동 상태 감지 불가!";

    print(status);
  }

  void _onStepCountError(error) {
    print('onStepCountError: $error');

    steps = "걸음수 측정 불가!";

    print(steps);
  }

  void initPlatformState(BuildContext context) {
    pedestrianStatusStream = Pedometer.pedestrianStatusStream;

    pedestrianStatusStream
        .listen(_onPedestrianStatusChanged)
        .onError(_onPedestrianStatusError);

    stepCountStream = Pedometer.stepCountStream;

    stepCountStream.listen(_onStepCount).onError(_onStepCountError);

    if (!context.mounted) return;
  }
}
