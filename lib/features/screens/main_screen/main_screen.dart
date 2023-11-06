// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:walker/constants/sizes.dart';
import 'package:walker/features/widgets/location_info.dart';
import 'package:walker/features/widgets/permission_handler.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static String routeName = "/main";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  /// GPS Initialize
  Position? currentPosition;

  /// Initialize Address
  String? currentAddress;

  /// Request & get Current Location
  Future<void> _determinePosition() async {
    LocationInfo locationInfo = LocationInfo();

    /// Get 위도, 경도, 주소
    try {
      Position position = await locationInfo.determinePermission();
      String address = await locationInfo.getCurrentAddress(
        position.latitude,
        position.longitude,
      );
      setState(() {
        currentPosition = position;
        currentAddress = address;
        print("현재 위치 값: $currentPosition");
        print("현재 주소: $currentAddress");
      });
    } catch(e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    /// Request user to permit location info
    AccessPermissionHandler permissionHandler = AccessPermissionHandler(context);
    permissionHandler.requestLocationPermission();

    /// Get Current Location
    _determinePosition();

    /// Update Location Info
    LocationInfo locationInfo = LocationInfo();
    locationInfo.getStreaming();
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
                child: Text(
                  currentPosition?.latitude.toString() ?? "위도 값 갱신중",
                  style: const TextStyle(
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
                child: Text(
                  currentPosition?.longitude.toString() ?? "경도 값 갱신중",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: Sizes.size16,
                  ),
                ),
              ),

              /// 주소 값
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
                child: Text(
                  "현재 위치는 $currentAddress 입니다.",
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: Sizes.size16,
                  ),
                ),
              ),

              /// 현재 걸음 수
              const Text(
                "현재 걸음 수",
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
                  "현재까지 500보 걸으셨네요!",
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
