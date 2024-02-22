import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:walker/common/widgets/fcm_controller.dart';
import 'package:walker/common/widgets/steps_manager.dart';
import 'package:walker/features/main_screen/main_screen.dart';
import 'package:walker/features/splash_screen/splash_screen.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage((message) async {
    var msgController = Get.put(MsgController());

    await msgController.onBackgroundHandler(message);
  });

  await SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );

  runZonedGuarded(() async {}, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  });

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  var now = DateTime.now();

  var tomorrow = DateTime(
    now.year,
    now.month,
    now.day + 1,
  );

  var remains = tomorrow.difference(now);

  var uniqueName = "일일 걸음수 저장";

  var taskName = "saveStepsTask";

  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  );

  await Workmanager().registerPeriodicTask(
    uniqueName,
    taskName,
    frequency: const Duration(hours: 24),
    initialDelay: Duration(milliseconds: remains.inMilliseconds),
  );

  runApp(const WalkerApp());
}

class WalkerApp extends StatelessWidget {
  const WalkerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "부럽",
      theme: ThemeData(
        primaryColor: const Color(0xFF38BEEF),
        useMaterial3: false,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: SplashScreen.routeName,
      routes: {
        SplashScreen.routeName: (context) => const SplashScreen(),
        MainScreen.routeName: (context) => const MainScreen(),
      },
    );
  }
}
