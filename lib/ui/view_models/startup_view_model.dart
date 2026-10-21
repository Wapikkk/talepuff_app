import 'package:flutter/material.dart';

import '../../data/models/auth_result.dart';
import '../../data/repositories/auth_repository.dart';

class StartupViewModel extends ChangeNotifier {
  StartupViewModel({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  bool isLoading = true;
  String? errorMessage;
  bool canChangeServer = false;

  Future<AuthResult> restore() async {
    isLoading = true;
    errorMessage = null;
    canChangeServer = false;
    notifyListeners();

    final result = await _repository.restoreSession();

    isLoading = false;
    if (result is AuthFailed) {
      errorMessage = result.message;
      canChangeServer = result.reason == AuthFailureReason.network;
    }
    notifyListeners();
    return result;
  }

  Future<void> signOut() => _repository.signOut();
}
