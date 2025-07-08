// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:to_do_list_app/services/auth.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _user;

  Map<String, dynamic>? get user => _user;

  bool get isLoggedIn => _user != null;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final userData = await AuthAPI.getCurrentUser();
    if (userData != null) {
      _user = userData;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    final success = await AuthAPI.login(email: email, password: password);
    if (success) {
      await loadUser();
    }
    return success;
  }

  Future<void> logout({bool remember = false}) async {
    if (!remember) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    }
    _user = null;
    notifyListeners();
  }

  Future<void> sendTokenToBackend(String? token) async {
    if (token == null) return;

    final user = await AuthAPI.getCurrentUser(); 
    if (user == null || user['id'] == null) return;

    final userId = user['id'];
    final url = Uri.parse('http://192.168.38.126:3000/auth/$userId/fcm-token');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        print('FCM token đã được gửi lên server');
      } else {
        print('Gửi token thất bại: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi gửi token: $e');
    }
  }
}
