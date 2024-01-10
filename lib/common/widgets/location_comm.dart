// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationCommunication {
  String? countryName;

  String? cityName;

  String? lat;

  String? lng;

  String date;

  String time;

  LocationCommunication({
    this.countryName,
    this.cityName,
    this.lat,
    this.lng,
    required this.date,
    required this.time,
  });

  Future<void> toJson(Map<String, dynamic> data) async {
    const String apiKey = "appUpdateCity.vn.php";

    var redirectUrl = "https://boolub.com/addons/app/request/$apiKey";

    var response = await http.post(
      Uri.parse(redirectUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );

    try {
      if (response.statusCode == 200) {
        print("POST Succeed: ${response.statusCode}");
        print("POST Data: $data");
      } else {
        print("POST Failed: ${response.statusCode} / ${response.body}");
      }
    } on Error catch (e) {
      print("웹 서버 통신 오류: $e");
    }
  }
}
