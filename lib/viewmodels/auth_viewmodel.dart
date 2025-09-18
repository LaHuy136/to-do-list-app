// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth.dart';
import '../models/user.dart';

class AuthViewModel extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load user từ token (nếu có) khi mở app
  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    final userData = await AuthAPI.getCurrentUser();
    if (userData != null) {
      _currentUser = User.fromJson(userData);
      notifyListeners();
    }
  }

  /// Đăng nhập
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    try {
      final success = await AuthAPI.login(email: email, password: password);
      if (success) {
        await loadUser();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Đăng ký
  Future<bool> register(String username, String email, String password) async {
    _setLoading(true);
    try {
      await AuthAPI.register(
        username: username,
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Cập nhật thông tin người dùng
  Future<bool> updateUser(
    String email,
    String username,
    String profession,
    String dateOfBirth,
  ) async {
    if (_currentUser == null) return false;
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return false;

    _setLoading(true);
    try {
      final success = await AuthAPI.updateUser(
        email: email,
        username: username,
        profession: profession,
        dateOfBirth: dateOfBirth,
      );

      if (success) {
        _currentUser = _currentUser!.copyWith(
          email: email,
          username: username,
          profession: profession,
          dateOfBirth: dateOfBirth,
        );
        notifyListeners();
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Xác minh mã
  Future<bool> verifyCode(String email, String code) async {
    _setLoading(true);
    try {
      final success = await AuthAPI.verifyCode(email, code);
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Gửi lại mã
  Future<bool> resendCode(String email) async {
    _setLoading(true);
    try {
      final success = await AuthAPI.resendCode(email);
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reset mật khẩu
  Future<bool> resetPassword(String email, String newPassword) async {
    _setLoading(true);
    try {
      final success = await AuthAPI.resetPassword(
        email: email,
        newPassword: newPassword,
      );
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Đổi mật khẩu
  Future<bool> updatePassword(
    String email,
    String currentPassword,
    String newPassword,
  ) async {
    _setLoading(true);
    try {
      final success = await AuthAPI.updatePassword(
        email: email,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Đăng xuất
  Future<void> logout({bool remember = false}) async {
    if (!remember) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    }
    _currentUser = null;
    notifyListeners();
  }

  /// Gửi FCM token lên backend để lưu
  Future<void> sendTokenToBackend(String? token) async {
    if (token == null) return;
    if (_currentUser == null) return;

    final userId = _currentUser!.id;
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

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
