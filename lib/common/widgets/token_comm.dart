// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

class FcmTokenCommunication {
  String? appId;

  String? token;

  FcmTokenCommunication({
    required this.appId,
    required this.token,
  });

  Future<void> toJson(Map<String, dynamic> data) async {
    const String apiKey = "pushUpdate.php";

    var redirectUrl = "https://boolub.com/addons/app/request/$apiKey";

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
