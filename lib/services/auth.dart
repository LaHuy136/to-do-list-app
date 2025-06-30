// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://192.168.38.126:3000/auth';

class AuthAPI {
  static Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/register');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return true;
    } else {
      print('Register error: ${res.body}');
      return false;
    }
  }

  static Future<bool> verifyEmail({
    required String email,
    required String code,
  }) async {
    final url = Uri.parse('$baseUrl/verify-code');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );

    if (res.statusCode == 200) {
      return true;
    } else {
      print('Verify error: ${res.body}');
      return false;
    }
  }

  static Future<dynamic> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      throw Exception(jsonDecode(response.body)['message'] ?? 'Login failed');
    }
  }

  static Future<bool> verifyCode(String email, String code) async {
    final url = Uri.parse('$baseUrl/verify-code');
    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );

    return res.statusCode == 200;
  }

  static Future<bool> resendCode(String email) async {
    final res = await http.post(
      Uri.parse('$baseUrl/resend-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    return res.statusCode == 200;
  }

  static Future<bool> updatePassword({
    required String email,
    required String newPassword,
  }) async {
    final url = Uri.parse('$baseUrl/forgot-password');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'newPassword': newPassword}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Update password failed');
    }
  }
}
