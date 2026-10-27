import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/models/account_result.dart';
import '../../../data/models/app_message.dart';
import '../../../data/repositories/feedback_repository.dart';

class FeedbackViewModel extends ChangeNotifier {
  FeedbackViewModel({required FeedbackRepository repository}) : _repository = repository;

  final FeedbackRepository _repository;
  Timer? _errorTimer;

  String category = 'idea';
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  AppMessage? error;

  void selectCategory(String value) {
    category = value;
    notifyListeners();
  }

  void reset() {
    _errorTimer?.cancel();
    category = 'idea';
    error = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<AccountResult?> send(String message) async {
    if (_isLoading) return null;
    _isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await _repository.send(category: category, message: message);
      if (result is AccountFailure) _setError(result.message);
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setError(AppMessage message) {
    error = message;
    notifyListeners();
    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 3), () {
      error = null;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    super.dispose();
  }
}
