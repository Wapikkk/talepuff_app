import 'package:flutter/material.dart';

import '../../data/models/app_message.dart';
import '../../data/models/auth_result.dart';
import '../../data/repositories/auth_repository.dart';

class StartupViewModel extends ChangeNotifier {
  StartupViewModel({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  bool isLoading = true;

  AppMessage? error;
  bool canChangeServer = false;

  Future<AuthResult> restore() async {
    isLoading = true;
    error = null;
    canChangeServer = false;
    notifyListeners();

    final result = await _repository.restoreSession();

    isLoading = false;
    if (result is AuthFailed) {
      error = result.message;
      canChangeServer = result.reason == AuthFailureReason.network;
    }
    notifyListeners();
    return result;
  }

  Future<void> signOut() => _repository.signOut();
}
