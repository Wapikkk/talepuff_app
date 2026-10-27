import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/account_result.dart';
import '../../../data/models/app_message.dart';
import '../../../data/repositories/account_repository.dart';

class UpdateSettingsViewModel extends ChangeNotifier {
  UpdateSettingsViewModel({required AccountRepository repository}) : _repository = repository;

  final AccountRepository _repository;
  Timer? _errorTimer;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AppMessage? error;

  bool get canManageCredentials => _repository.canManageCredentials;

  Future<AccountResult?> updateChildName({required String? childId, required String name}) {
    final id = int.tryParse(childId ?? '');
    if (id == null) {
      _setError(AppMessage.childDataNotLoaded);
      return Future.value(const AccountFailure(AppMessage.childDataNotLoaded));
    }
    return _run(() => _repository.updateChildName(childId: id, name: name));
  }

  Future<AccountResult?> updateMascot({required String? childId, required String mascotId}) {
    final id = int.tryParse(childId ?? '');
    if (id == null) {
      _setError(AppMessage.childDataNotLoaded);
      return Future.value(const AccountFailure(AppMessage.childDataNotLoaded));
    }
    return _run(() => _repository.updateMascot(childId: id, mascotId: mascotId));
  }

  Future<AccountResult?> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) {
    return _run(() => _repository.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
          confirmPassword: confirmPassword,
        ));
  }

  Future<AccountResult?> requestEmailChange({required String newEmail, required String currentPassword}) {
    return _run(() => _repository.requestEmailChange(newEmail: newEmail, currentPassword: currentPassword));
  }

  void clearError() {
    if (error == null) return;
    _errorTimer?.cancel();
    error = null;
    notifyListeners();
  }

  Future<AccountResult?> _run(Future<AccountResult> Function() action) async {
    if (_isLoading) return null;
    _isLoading = true;
    error = null;
    notifyListeners();
    try {
      final result = await action();
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
