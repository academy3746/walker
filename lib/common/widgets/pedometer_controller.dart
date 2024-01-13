// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walker/common/widgets/steps_manager.dart';
import 'package:workmanager/workmanager.dart';

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

    await onStepCountUpdate(currentSteps);

    print("Streaming Steps Count: $currentSteps");

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("currentSteps", currentSteps);

    if (prefs.getInt("initialSteps") == null) {
      await prefs.setInt("initialSteps", currentSteps);
    } else if (prefs.getInt("initialSteps") != null) {
      var initialSteps = prefs.getInt("initialSteps") ?? 0;

      var newSteps = currentSteps - initialSteps;

      await prefs.setInt("newSteps", newSteps);
    }
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
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    await Workmanager().registerPeriodicTask(
      "1",
      "saveStepsTask",
      frequency: const Duration(days: 1),
    );

    stepCountStream = Pedometer.stepCountStream;

    pedestrianStatusStream = Pedometer.pedestrianStatusStream;

    pedestrianStatusStream
        .listen(_onPedestrianStatusChanged)
        .onError(_onPedestrianStatusError);

    stepCountStream.listen(_onStepCount).onError(_onStepCountError);

    await _initDailyTimer();

    if (!context.mounted) return;
  }

  /// Timer Reset (일일 단위)
  Future<void> _initDailyTimer() async {
    var oneDay = const Duration(days: 1);

    //var debug = const Duration(minutes: 2);

    Timer(oneDay, () async {
      await _saveTodaySteps();
      //print("걸음수가 초기화 되었습니다!");

      Timer.periodic(oneDay, (timer) async {
        await _saveTodaySteps();
        //print("걸음수가 초기화 되었습니다!");
      });
    });
  }

  /// 프그라운드 상태에서 걸음수 저장
  Future<void> _saveTodaySteps() async {
    var savedSteps = currentSteps;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt("savedSteps", savedSteps);
  }
}
