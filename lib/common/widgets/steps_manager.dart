import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

Future<void> callbackDispatcher() async {
  WidgetsFlutterBinding.ensureInitialized();

  var now = DateTime.now();

  var midnight = DateTime(
    now.year,
    now.month,
    now.day + 1,
  );

  final prefs = await SharedPreferences.getInstance();

  var currentSteps = prefs.getInt("currentSteps") ?? 0;

  Workmanager().executeTask((taskName, inputData) async {
    if (now.isAfter(midnight)) {
      await prefs.setInt("savedSteps", currentSteps);
    }

    return Future.value(true);
  });
}

class StepsManager {
  int? steps;

  StepsManager({required this.steps});
}
