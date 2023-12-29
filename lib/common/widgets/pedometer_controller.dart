// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PedometerController {
  /// 총 걸음수 구독
  Stream<StepCount> stepCountStream;

  /// 운동 상태 구독
  Stream<PedestrianStatus> pedestrianStatusStream;

  /// 운동 상태
  String status;

  /// 현재 걸음수
  int currentSteps = 0;

  /// 걸음 수 업데이트
  final Function(int) onStepCountUpdate;

  /// 운동 상태 업데이트
  final Function(String) onPedestrianStatusUpdate;

  PedometerController({
    required this.stepCountStream,
    required this.pedestrianStatusStream,
    required this.status,
    required this.currentSteps,
    required this.onStepCountUpdate,
    required this.onPedestrianStatusUpdate,
  });

  Future<void> _onStepCount(StepCount event) async {
    currentSteps = event.steps;

    onStepCountUpdate(currentSteps);

    print("Now Walking: $currentSteps");
  }

  Future<void> _saveTodaySeps() async {
    int savedSteps = currentSteps;

    var savedDatetime = DateTime.now().millisecondsSinceEpoch;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("savedSteps", savedSteps);

    await prefs.setInt("savedDatetime", savedDatetime);

    print("Today Total Steps: $savedSteps");
    print("Last Saved Datetime: $savedDatetime");
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

    Timer.periodic(const Duration(days: 1), (t) => _saveTodaySeps());

    if (!context.mounted) return;
  }
}
