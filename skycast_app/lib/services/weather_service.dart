import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static Future<Map<String, dynamic>> fetchWeather(String city) async {
    final url = Uri.parse(
      'http://10.207.2.24:8000/weather?city=$city',
    );

    final response = await http.get(url);

    if (kDebugMode) {
      debugPrint("Weather API Status: ${response.statusCode}");
      debugPrint("Weather API Response: ${response.body}");
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data.containsKey('error')) {
        throw Exception(data['error']);
      }

      data["recommendation"] = data["recommendation"] ?? "N/A";
      data["risk_score"] = data["risk_score"] ?? 0;

      return data;
    } else {
      throw Exception('Failed to load weather');
    }
  }

  static Future<void> sendFcmToken(String token) async {
  final url = Uri.parse('http://10.207.2.24:8000/register-token');

  try {
    await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token}),
    );
    print("FCM token sent to backend");
  } catch (e) {
    print("Error sending FCM token: $e");
  }
}
}
