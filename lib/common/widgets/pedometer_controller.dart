// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

class PedometerController {
  final Function(String) onStepCountUpdate;

  final Function(String) onPedestrianStatusUpdate;

  Stream<StepCount> stepCountStream;

  Stream<PedestrianStatus> pedestrianStatusStream;

  String status;

  String steps;

  PedometerController({
    required this.onStepCountUpdate,
    required this.onPedestrianStatusUpdate,
    required this.stepCountStream,
    required this.pedestrianStatusStream,
    required this.status,
    required this.steps,
  });

  void _onStepCount(StepCount event) {
    print("이벤트 감지: $event");

    steps = event.steps.toString();

    onStepCountUpdate(steps);
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    print("이벤트 감지: $event");

    status = event.status;

    onPedestrianStatusUpdate(status);
  }

  void _onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');

    status = "걸음 상태 감지 불가!";

    print(status);
  }

  void _onStepCountError(error) {
    print('onStepCountError: $error');

    steps = "걸음 수 측정 불가!";

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
