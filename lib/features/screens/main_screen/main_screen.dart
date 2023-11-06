import 'package:flutter/material.dart';
import 'package:walker/constants/sizes.dart';
import 'package:walker/features/widgets/permission_handler.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static String routeName = "/main";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  @override
  void initState() {
    super.initState();

    /// Request User Permission
    AccessPermissionHandler permissionHandler = AccessPermissionHandler(context);
    permissionHandler.requestPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Demo Application",
          style: TextStyle(
            color: Colors.black,
            fontSize: Sizes.size24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(
            Sizes.size24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              /// 위도 값
              const Text(
                "위도",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: Sizes.size20,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  top: Sizes.size10,
                  bottom: Sizes.size24,
                ),
                child: const Text(
                  "Hey!",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: Sizes.size16,
                  ),
                ),
              ),

              /// 경도 값
              const Text(
                "경도",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: Sizes.size20,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  top: Sizes.size10,
                  bottom: Sizes.size24,
                ),
                child: const Text(
                  "Jude!",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: Sizes.size16,
                  ),
                ),
              ),

              /// 위치 환산 into String
              const Text(
                "현재 위치",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: Sizes.size20,
                ),
              ),
              Container(
                margin: const EdgeInsets.only(
                  top: Sizes.size10,
                  bottom: Sizes.size24,
                ),
                child: const Text(
                  "현재 위치는 인천 입니다.",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: Sizes.size16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
