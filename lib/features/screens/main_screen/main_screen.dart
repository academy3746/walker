// ignore_for_file: avoid_print

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:walker/constants/sizes.dart';
import 'package:walker/features/widgets/health_permission_handler.dart';
import 'package:walker/features/widgets/location_info.dart';
import 'package:walker/features/widgets/location_permission_handler.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static String routeName = "/main";

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  /// Import Location Info
  LocationInfo locationInfo = LocationInfo();

  /// GPS Initialize
  Position? currentPosition;

  /// Initialize Address
  String? currentAddress;

  /// Get Current Location Values
  Future<void> _determinePosition() async {
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
    } catch (e) {
      print(e);
    }
  }

  /// Request Location Access Permission & Get Current Place
  Future<void> _requestAndDetermineLocation() async {
    AccessLocationPermissionHandler permissionHandler =
        AccessLocationPermissionHandler();
    bool hasLocPermission = await permissionHandler.requestLocationPermission();

    if (hasLocPermission) {
      print("위치정보 접근 권한이 허용되었습니다.");

      await _determinePosition();
      locationInfo.getStreaming();
    } else {
      print("위치정보 접근 권한이 거부되었습니다.");
    }
  }

  Future<void> _determineHealthData() async {
    AccessHealthPermissionHandler permissionHandler = AccessHealthPermissionHandler();
    bool hasPermission = await permissionHandler.requestHealthPermission();

    if (hasPermission) {
      print("신체 활동 접근 권한이 허용되었습니다.");
    } else {
      print("신체 활동 접근 권한이 거부되었습니다.");
    }
  }

  @override
  void initState() {
    super.initState();

    _requestAndDetermineLocation();
    //_determineHealthData();
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
                  "현재까지 500걸음 걸으셨네요!",
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
