// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class StepsCommunication {
  int steps;

  String date;

  StepsCommunication({
    required this.steps,
    required this.date,
  });

  Future<void> toJson(Map<String, dynamic> data) async {
    const String apiKey = "appUpdateSteps.vn.php";

    var redirectUrl = "https://www.boolub.com/addons/app/request/$apiKey";

    var response = await http.post(
      Uri.parse(redirectUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );

    try {
      if (response.statusCode == 200) {
        print("POST Succeed: ${response.statusCode}");
        print("Redirect URL: $redirectUrl");
        print("POST Data: $data");
      } else {
        print("POST Failed: ${response.statusCode} / ${response.body}");
      }
    } on Error catch (e) {
      print("웹 서버 통신 오류: $e");
    }
  }
}
