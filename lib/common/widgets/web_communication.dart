// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class WebServerCommunication {
  final String steps;

  Position? currentPosition;

  String? currentAddress;

  WebServerCommunication({
    required this.steps,
    this.currentPosition,
    this.currentAddress,
  });

  /// Send API to Web Server
  Future<void> toJson(Map<String, dynamic> toJson) async {
    const String redirectUrl = "https://boolub.com/?is_app=y";

    var response = await http.post(
      Uri.parse(redirectUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(toJson),
    );

    try {
      if (response.statusCode == 200) {
        print("POST Succeed: ${response.statusCode}");
      } else {
        print("POST Failed: ${response.statusCode}");
      }
    } on Error catch (e) {
      print("웹 서버 통신 오류: $e");
    }
  }
}
