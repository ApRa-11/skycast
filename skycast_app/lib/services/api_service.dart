import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DisasterResponse {
  final String disasterType;
  final String severity;
  final List<String> safetyTips;
  final String recommendation; // new field
  final int riskScore; // new field

  DisasterResponse({
    required this.disasterType,
    required this.severity,
    required this.safetyTips,
    required this.recommendation,
    required this.riskScore,
  });

  factory DisasterResponse.fromJson(Map<String, dynamic> json) {
    return DisasterResponse(
      disasterType: json["disaster_type"] ?? "Unknown",
      severity: json["severity"] ?? "Unknown",
      safetyTips: List<String>.from(json["safety_tips"] ?? []),
      recommendation: json["recommendation"] ?? "N/A",
      riskScore: json["risk_score"] ?? 0,
    );
  }
}

class ApiService {
  static const String baseUrl = "http://10.207.2.24:8000";

  static Future<DisasterResponse?> predictDisaster({
    required double temperature,
    required double humidity,
    required double precipitation,
    required double windSpeed,
  }) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/predict_disaster"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "Temperature_C": temperature,
          "Humidity_pct": humidity,
          "Precipitation_mm": precipitation,
          "Wind_Speed_kmh": windSpeed,
        }),
      );

      if (kDebugMode) {
        debugPrint("Disaster API Status: ${response.statusCode}");
        debugPrint("Disaster API Response: ${response.body}");
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DisasterResponse.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint("API Error: $e");
      }
      return null;
    }
  }
}
