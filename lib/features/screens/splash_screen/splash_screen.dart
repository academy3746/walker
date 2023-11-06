import 'package:flutter/material.dart';
import 'package:walker/constants/sizes.dart';
import 'package:walker/features/screens/main_screen/main_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static String routeName = "/";

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, MainScreen.routeName);
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(
          Sizes.size20,
        ),
        child: Center(
          child: Align(
            alignment: Alignment.center,
            child: Image.asset(
              "assets/images/splash.png",
              width: Sizes.size150 + Sizes.size50,
              height: Sizes.size150 + Sizes.size50,
            ),
          )
        ),
      ),
    );
  }
}
