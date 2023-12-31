// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:http/http.dart' as http;

class WebServerCommunication {
  final int currentSteps;

  String? currentAddress;

  String? token;

  String? currentPosition;

  final String version;

  final String appId;

  final String os;

  final String agent;

  int? savedSteps;

  int? todaySteps;

  WebServerCommunication({
    required this.currentSteps,
    this.currentAddress,
    this.token,
    this.currentPosition,
    required this.version,
    required this.appId,
    required this.os,
    required this.agent,
    this.savedSteps,
    this.todaySteps,
  });

  /// Send API to Web Server
  Future<void> toJson(Map<String, dynamic> data) async {
    const String redirectUrl =
        "https://boolub.com/addons/app/request/pushUpdate.php";

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
        print("POST Failed: ${response.statusCode}");
      }
    } on Error catch (e) {
      print("웹 서버 통신 오류: $e");
    }
  }
}
