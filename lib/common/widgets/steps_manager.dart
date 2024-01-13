// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

Future<void> callbackDispatcher() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  var currentSteps = prefs.getInt("currentSteps") ?? 0;

  Workmanager().executeTask((taskName, inputData) async {
    await prefs.setInt("savedSteps", currentSteps);

    return Future.value(true);
  });
}
