// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PedometerController {
  /// 걸음수 구독
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

  /// 걸음수 구독 (Realtime)
  Future<void> _onStepCount(StepCount event) async {
    currentSteps = event.steps;

    onStepCountUpdate(currentSteps);

    print("Now Walking: $currentSteps");

    final prefs = await SharedPreferences.getInstance();

    if (prefs.getInt("savedSteps") == 0 ||
        prefs.getInt("initialSteps") == null) {
      await prefs.setInt("initialSteps", currentSteps);
    }
  }

  /// 걸음수 저장 (일일 단위)
  Future<void> _saveTodaySeps() async {
    int savedSteps = currentSteps;

    var savedDatetime = DateTime.now().millisecondsSinceEpoch;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("savedSteps", savedSteps);

    await prefs.setInt("savedDatetime", savedDatetime);
  }

  /// 운동 상태 감지 이벤트
  void _onPedestrianStatusChanged(PedestrianStatus event) {
    status = event.status;

    onPedestrianStatusUpdate(status);

    print("운동 상태: ${event.status}");
  }

  /// 운동 상태 에러 헨들링
  void _onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
  }

  /// 걸음 수 구독 에러 헨들링
  void _onStepCountError(error) {
    print('onStepCountError: $error');
  }

  /// Pedometer Controller 초기화
  Future<void> initPlatformState(BuildContext context) async {
    stepCountStream = Pedometer.stepCountStream;

    pedestrianStatusStream = Pedometer.pedestrianStatusStream;

    pedestrianStatusStream
        .listen(_onPedestrianStatusChanged)
        .onError(_onPedestrianStatusError);

    stepCountStream.listen(_onStepCount).onError(_onStepCountError);

    /*Timer.periodic(
      const Duration(days: 1),
      (timer) async => await _saveTodaySeps(),
    );*/

    await _initTimer();

    if (!context.mounted) return;
  }

  /// Reset Timer (일일 단위)
  Future<void> _initTimer() async {
    var now = DateTime.now();

    var nextMidnight = DateTime(
      now.year,
      now.month,
      now.day + 1,
    );

    var initDelay = nextMidnight.difference(now);

    Timer(initDelay, () async {
      await _saveTodaySeps();

      Timer.periodic(
        const Duration(days: 1),
        (timer) async => await _saveTodaySeps(),
      );
    });
  }
}
