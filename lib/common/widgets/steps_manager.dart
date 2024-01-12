// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:walker/common/widgets/fcm_controller.dart';
import 'package:workmanager/workmanager.dart';

Future<void> callbackDispatcher() async {
  WidgetsFlutterBinding.ensureInitialized();

  MsgController msgController = MsgController();

  var now = DateTime.now();

  var todayMidnight = DateTime(
    now.year,
    now.month,
    now.day,
  );

  var nextMidnight = DateTime(
    now.year,
    now.month,
    now.day + 1,
  );

  final prefs = await SharedPreferences.getInstance();

  var currentSteps = prefs.getInt("currentSteps") ?? 0;

  Workmanager().executeTask((taskName, inputData) async {
    if (todayMidnight.isAfter(nextMidnight)) {
      await prefs.setInt("savedSteps", currentSteps);

      await msgController.sendInternalPush(
        "수고하셨어요!",
        "내일도 응원 할게요 💕",
      );
    }

    return Future.value(true);
  });
}

class StepsManager {
  int? steps;

  StepsManager({required this.steps});
}
