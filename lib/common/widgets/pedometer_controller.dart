// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

class PedometerController {
  /// 총 걸음수 구독
  Stream<StepCount> stepCountStream;

  /// 운동 상태 구독
  Stream<PedestrianStatus> pedestrianStatusStream;

  /// 운동 상태
  String status;

  /// 총 걸음수
  int steps;

  /// 걸음 수 업데이트
  final Function(int) onStepCountUpdate;

  /// 운동 상태 업데이트
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
    int calculatedSteps = event.steps;

    onStepCountUpdate(calculatedSteps);

    print("Now Walking: $calculatedSteps");
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    status = event.status;

    onPedestrianStatusUpdate(status);

    print("운동 상태: ${event.status}");
  }

  void _onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
  }

  void _onStepCountError(error) {
    print('onStepCountError: $error');
  }

  void initPlatformState(BuildContext context) {
    stepCountStream = Pedometer.stepCountStream;

    pedestrianStatusStream = Pedometer.pedestrianStatusStream;

    pedestrianStatusStream
        .listen(_onPedestrianStatusChanged)
        .onError(_onPedestrianStatusError);

    stepCountStream.listen(_onStepCount).onError(_onStepCountError);

    if (!context.mounted) return;
  }
}
