import 'package:flutter/foundation.dart';
import 'package:to_do_list_app/services/message.dart';

class MessageViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  Future<void> sendMessage({
    required int userId,
    required String subject,
    required String message,
  }) async {
    _setLoading(true);
    _errorMessage = null;
    _isSuccess = false;

    try {
      await MessageAPI.sendMessage(
        userId: userId,
        subject: subject,
        message: message,
      );
      _isSuccess = true;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }
}
