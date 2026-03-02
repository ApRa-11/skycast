import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WeatherService {
  static Future<Map<String, dynamic>> fetchWeather(String city) async {
    final url = Uri.parse(
      'http://localhost:8000/weather?city=$city',
    );

    final response = await http.get(url);

    // Debug logging (only runs in debug mode)
    if (kDebugMode) {
      debugPrint("Weather API Status: ${response.statusCode}");
      debugPrint("Weather API Response: ${response.body}");
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data.containsKey('error')) {
        throw Exception(data['error']);
      }

      // Ensure new fields exist
      data["recommendation"] = data["recommendation"] ?? "N/A";
      data["risk_score"] = data["risk_score"] ?? 0;

      return data;
    } else {
      throw Exception('Failed to load weather');
    }
  }
}
