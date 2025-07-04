import 'dart:convert';
import 'package:http/http.dart' as http;

class MessageAPI {
  static const String baseUrl = 'http://192.168.38.126:3000/message';

  static Future<void> sendMessage({
    required int userId,
    required String subject,
    required String message,
  }) async {
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'subject': subject,
        'message': message,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(
        jsonDecode(response.body)['message'] ?? 'Failed to send message',
      );
    }
  }
}
