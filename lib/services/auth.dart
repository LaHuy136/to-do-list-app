// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  static Future<bool> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Lưu vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', data['token']);
      return true;
    } else {
      throw Exception(jsonDecode(response.body)['message'] ?? 'Login failed');
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return null;

    final response = await http.get(
      Uri.parse('$baseUrl/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['user'];
    } else {
      print('Failed to load user: ${response.body}');
      await prefs.remove('token');
      return null;
    }
  }

  static Future<bool> updateUser({
    required String email,
    required String username,
    required String profession,
    required String dateOfBirth,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$baseUrl/update');

    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'email': email,
        'username': username,
        'profession': profession,
        'dateofbirth': dateOfBirth,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Update failed: ${response.body}');
      return false;
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
