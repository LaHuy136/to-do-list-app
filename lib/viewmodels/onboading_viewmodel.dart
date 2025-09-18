import 'package:flutter/material.dart';
import '../models/onboarding.dart';
import '../services/onboarding.dart';

class OnboardingViewModel extends ChangeNotifier {
  List<OnboardingData> _onboardingList = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OnboardingData> get onboardingList => _onboardingList;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  /// Fetch onboarding
  Future<void> fetchOnboarding() async {
    _setLoading(true);
    try {
      final data = await OnboardingAPI.fetchOnboarding();
      _onboardingList = data;
      _errorMessage = null;
    } catch (e) {
      _setError(e.toString());
      _onboardingList = [];
    } finally {
      _setLoading(false);
    }
  }
}
