import 'package:flutter/material.dart';
import 'package:walker/features/screens/main_screen/main_screen.dart';
import 'package:walker/features/screens/splash_screen/splash_screen.dart';

void main() {
  runApp(const WalkerApp());
}

class WalkerApp extends StatelessWidget {
  const WalkerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.blueAccent,
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
