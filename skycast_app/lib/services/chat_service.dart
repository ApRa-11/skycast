import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static const String baseUrl = "http://127.0.0.1:8000";

  static Future<String> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/chat"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"session_id": "user123", "message": message,}),
        );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data["reply"] ?? "No response";
      } else {
        return "⚠️ Server error";
      }
    } catch (e) {
      return "⚠️ Connection failed";
    }
  }
}