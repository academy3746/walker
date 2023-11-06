// ignore_for_file: avoid_print

import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class LocationInfo {
  Position? lastPosition;

  /// 위치 정보값 Update
  void getStreaming() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 500,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        if (lastPosition == null) {
          lastPosition = position;
        } else if (lastPosition!.latitude != position.latitude ||
            lastPosition!.longitude != position.longitude) {
          print("위치 정보 업데이트: $lastPosition");
          lastPosition = position;
        }
      },
    );
  }

  /// 위도 및 경도값 GET
  Future<Position> determinePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      print("GPS 서비스가 비활성화 된 상태입니다.");
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        print("사용자에 의해 GPS 접근 권한이 거부되었습니다!");
      }
    }

    return await Geolocator.getCurrentPosition(
      timeLimit: const Duration(seconds: 30),
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

        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          result = place.subLocality!;
        } else if (place.locality != null && place.locality!.isNotEmpty) {
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
}
