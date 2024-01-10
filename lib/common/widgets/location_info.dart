// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:walker/common/widgets/fcm_controller.dart';

class LocationInfo {
  Position? lastPosition;

  String? lastCountryCode;

  late LocationSettings locationSettings;

  MsgController msgController = MsgController();

  /// 위도 및 경도값 GET
  Future<Position> determinePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      print("위치정보 서비스가 비활성화 된 상태입니다.");
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        print("사용자에 의해 위치정보 접근 권한이 거부되었습니다!");
      }
    }

    return await Geolocator.getCurrentPosition(
      timeLimit: const Duration(seconds: 10),
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  /// 위도 및 경도값을 주소 Format으로 타입 변경
  Future<String> getCurrentAddress(double latitude, double longitude) async {
    try {
      List<geocoding.Placemark> placeMarks =
          await geocoding.placemarkFromCoordinates(latitude, longitude);

      if (placeMarks.isNotEmpty) {
        geocoding.Placemark place = placeMarks.first;

        String result = "";

        if (place.locality != null && place.locality!.isNotEmpty) {
          result = place.locality!;
        } else if (place.subAdministrativeArea != null &&
            place.subAdministrativeArea!.isNotEmpty) {
          result = place.subAdministrativeArea!;
        } else if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          result = place.administrativeArea!;
        } else if (place.country != null && place.country!.isNotEmpty) {
          result = place.country!;
        }

        return result;
      }
      return "주소를 찾을 수 없는 위치입니다!";
    } catch (e) {
      print(e);
      return "주소 변환 중 오류가 발생하였습니다!";
    }
  }

  /// 해당 국가명 GET
  Future<String> getCountryName(double latitude, double longitude) async {
    try {
      List<geocoding.Placemark> placeMarks =
      await geocoding.placemarkFromCoordinates(latitude, longitude);

      if (placeMarks.isNotEmpty) {
        geocoding.Placemark place = placeMarks.first;

        String result = "";

        if (place.country != null && place.country!.isNotEmpty) {
          result = place.country!;
        }

        return result;
      }

      return "해당 지역의 국가 정보를 갱신할 수 없습니다.";
    } catch (e) {
      print(e);

      return "주소 변환 중 오류가 발생하였습니다.";
    }
  }

  /// 해당 국가 ISO Code GET
  Future<String?> getCountryCode(Position position) async {
    try {
      List<geocoding.Placemark> placeMarks = await geocoding
          .placemarkFromCoordinates(position.latitude, position.longitude);

      var country = placeMarks.first.isoCountryCode;

      return country;
    } catch (e) {
      print("Fail to get National Code: $e");

      return null;
    }
  }

  /// 위치 변경 여부 Check
  bool hasLocationChanged(Position position) {
    if (lastPosition == null) {
      lastPosition = position;

      return false;
    }

    double distance = Geolocator.distanceBetween(
      lastPosition!.latitude,
      lastPosition!.longitude,
      position.latitude,
      position.longitude,
    );

    if (distance >= 500) {
      lastPosition = position;

      return true;
    }

    return false;
  }

  Future<void> incheonAirport(Position currentPosition) async {
    const double portLat = 37.4493342;

    const double portLng = 126.4513395;

    double distanceToAirport = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      portLat,
      portLng,
    );

    if (distanceToAirport <= 500) {
      msgController.sendInternalPush(
        "인천국제공항에 도착하셨습니다.",
        "즐거운 여행 되세요!",
      );
    }
  }

  /// Location Changed (국가 단위)
  Future<void> getStreaming() async {
    var androidPlatform = TargetPlatform.android;

    var iosPlatform = TargetPlatform.iOS;

    if (defaultTargetPlatform == androidPlatform) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 500,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
      );
    } else if (defaultTargetPlatform == iosPlatform) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.best,
        activityType: ActivityType.fitness,
        distanceFilter: 500,
        timeLimit: const Duration(seconds: 10),
        pauseLocationUpdatesAutomatically: false,
        allowBackgroundLocationUpdates: true,
        showBackgroundLocationIndicator: false,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 500,
      );
    }

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) async {
        if (hasLocationChanged(position)) {
          lastPosition = position;

          String? currentCountryCode = await getCountryCode(position);

          if (lastCountryCode != currentCountryCode) {
            print("국가 정보 업데이트: $currentCountryCode");
            lastCountryCode = currentCountryCode;

            String currentAddress =
                await getCurrentAddress(position.latitude, position.longitude);

            print("도시 정보 업데이트: $currentAddress");

            await msgController.sendInternalPush(
              "$currentAddress에서 여행중이시네요!",
              "주변 맛집을 알려드릴게요!",
            );
          }

          await incheonAirport(position);

          print("위치 정보 업데이트: ${position.toString()}");
        }
      },
    );
  }

  /// Debug Location Changed
  Future<void> debugStreaming() async {
    // Chitose
    //const double debugLatitude = 42.7791302;
    //const double debugLongitude = 141.6866374;

    // 인천국제공항
    const double debugLatitude = 37.4493342;
    const double debugLongitude = 126.4513395;

    Future.delayed(
      const Duration(seconds: 5),
      () async {
        Position debugPosition = Position(
          latitude: debugLatitude,
          longitude: debugLongitude,
          timestamp: DateTime.now(),
          accuracy: 100.0,
          altitude: 0.0,
          heading: 0.0,
          speed: 0.0,
          speedAccuracy: 100.0,
          altitudeAccuracy: 100.0,
          headingAccuracy: 100.0,
        );

        if (hasLocationChanged(debugPosition)) {
          String? currentCountryCode = await getCountryCode(debugPosition);

          if (lastCountryCode != currentCountryCode) {
            print("국가 정보 업데이트: $currentCountryCode");
            lastCountryCode = currentCountryCode;

            String currentAddress = await getCurrentAddress(
                debugPosition.latitude, debugPosition.longitude);
            print("도시 정보 업데이트: $currentAddress");

            msgController.sendInternalPush(
              "$currentAddress를 여행중이시네요!",
              "주변 맛집을 알려드릴게요!",
            );
          }

          await incheonAirport(debugPosition);

          print("위치 정보 업데이트: ${debugPosition.toString()}");

          lastPosition = debugPosition;
        }
      },
    );
  }
}
