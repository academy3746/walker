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

  Future<void> _onStepCount(StepCount event) async {
    var currentSteps = event.steps;

    var now = DateTime.now();

    var endOfDay = DateTime(
      now.year,
      now.month,
      now.day,
      23,
      59,
      59,
    );

    onStepCountUpdate(currentSteps);

    print("Current Steps: $currentSteps");

    if (now.isAtSameMomentAs(endOfDay)) {
      await _saveTodaySeps(
        savedSteps: currentSteps,
        savedDatetime: now.millisecondsSinceEpoch,
      );

      print("오늘의 총 걸음수: $currentSteps");
      print("마지막 저장 시간: $now");
    }
  }

  Future<void> _saveTodaySeps({
    required int savedSteps,
    required int savedDatetime,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("savedSteps", savedSteps);

    await prefs.setInt("savedDatetime", savedDatetime);
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
