// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walker/common/widgets/fcm_controller.dart';

class PedometerController {
  /// 걸음수 구독
  Stream<StepCount> stepCountStream;

  /// 운동 상태 구독
  Stream<PedestrianStatus> pedestrianStatusStream;

  /// 운동 상태
  String status;

  /// 현재 걸음수
  int currentSteps;

  /// 걸음 수 업데이트
  final Function(int) onStepCountUpdate;

  /// 운동 상태 업데이트
  final Function(String) onPedestrianStatusUpdate;

  /// Push Event Flag
  final MsgController msgController = MsgController();

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

    print("Streaming Steps Count: $currentSteps");

    final prefs = await SharedPreferences.getInstance();

    if (prefs.getInt("initialSteps") == null) {
      await prefs.setInt("initialSteps", currentSteps);
    } else if (prefs.getInt("initialSteps") != null) {
      var initialSteps = prefs.getInt("initialSteps") ?? 0;

      var newSteps = currentSteps - initialSteps;

      await prefs.setInt("newSteps", newSteps);
    }
  }

  /// 걸음수 저장 (일일 단위)
  Future<void> _saveTodaySteps() async {
    int savedSteps = currentSteps;

    var now = DateTime.now().millisecondsSinceEpoch;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("savedSteps", savedSteps);

    await prefs.setInt("savedTime", now);
  }

  /// 운동 상태 감지 이벤트
  void _onPedestrianStatusChanged(PedestrianStatus event) {
    status = event.status;

    onPedestrianStatusUpdate(status);

    print("운동 상태: ${event.status}");
  }

  /// 운동 상태 에러 헨들링
  void _onPedestrianStatusError(error) {
    print("onPedestrianStatusError: $error");
  }

  /// 걸음 수 구독 에러 헨들링
  void _onStepCountError(error) {
    print("onStepCountError: $error");
  }

  /// Pedometer Controller 초기화
  Future<void> initPlatformState(BuildContext context) async {
    stepCountStream = Pedometer.stepCountStream;

    pedestrianStatusStream = Pedometer.pedestrianStatusStream;

    pedestrianStatusStream
        .listen(_onPedestrianStatusChanged)
        .onError(_onPedestrianStatusError);

    stepCountStream.listen(_onStepCount).onError(_onStepCountError);

    await _initDailyTimer();

    await _pushEventTrigger();

    if (!context.mounted) return;
  }

  /// Timer Reset (일일 단위)
  Future<void> _initDailyTimer() async {
    var now = DateTime.now();

    var midnight = DateTime(
      now.year,
      now.month,
      now.day + 1,
    );

    var oneDay = midnight.difference(now).inMilliseconds;

    var diff = Duration(milliseconds: oneDay);

    Timer(diff, () async {
      await _saveTodaySteps();

      Timer.periodic(const Duration(days: 1), (timer) async {
        await _saveTodaySteps();
      });
    });
  }

  /// 1만 걸음 달성 Push Event
  Future<void> _pushEventTrigger() async {
    final prefs = await SharedPreferences.getInstance();

    var lastSavedSteps = prefs.getInt("savedSteps") ?? 0;

    var dailySteps = currentSteps - lastSavedSteps;

    await prefs.setInt("savedDailySteps", dailySteps);

    var savedDailySteps = prefs.getInt("savedDailySteps") ?? 0;

    if (savedDailySteps >= 10000) {
      await msgController.sendInternalPush(
        "축하드려요!",
        "🏃‍♀️ 오늘 하루만 총 $savedDailySteps 걸음 걸으셨어요! 💕",
      );
    }
  }
}
