import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/validators.dart';
import '../../../data/models/app_message.dart';
import '../../../data/models/auth_result.dart';
import '../../../data/repositories/auth_repository.dart';
import '../parents/child_info_view_model.dart';

class SignUpViewModel extends ChangeNotifier {
  SignUpViewModel({
    required AuthRepository repository,
    required this.childInfoViewModel,
  }) : _repository = repository;

  final AuthRepository _repository;
  final ChildInfoViewModel childInfoViewModel;
  Timer? _errorTimer;

  String email = '', password = '';
  bool isAccepted = false;

  AppMessage? error;
  bool _isPasswordObscured = true;
  bool get isPasswordObscured => _isPasswordObscured;

  AuthMethod? _activeMethod;
  AuthMethod? get activeMethod => _activeMethod;
  bool get isLoading => _activeMethod != null;

  void updateEmail(String value) {
    email = value;
    error = null;
    notifyListeners();
  }

  void updatePassword(String value) {
    password = value;
    error = null;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordObscured = !_isPasswordObscured;
    notifyListeners();
  }

  void toggleAccepted(bool value) {
    isAccepted = value;
    notifyListeners();
  }

  Future<AuthResult> signUpManual() async {
    final emailIssue = AuthValidators.emailIssue(email);
    if (emailIssue != null) return _reject(emailIssue);

    final passwordIssue = AuthValidators.newPasswordIssue(password);
    if (passwordIssue != null) return _reject(passwordIssue);

    final precondition = _commonPreconditions();
    if (precondition != null) return precondition;

    return _run(
      AuthMethod.email,
      () => _repository.signUpWithEmail(email.trim(), password.trim(), childInfoViewModel.toDraft()),
    );
  }

  Future<AuthResult> signUpWithGoogle() async {
    final precondition = _commonPreconditions();
    if (precondition != null) return precondition;

    return _run(
      AuthMethod.google,
      () => _repository.signUpWithGoogle(childInfoViewModel.toDraft()),
    );
  }

  AuthResult? _commonPreconditions() {
    if (!isAccepted) return _reject(AppMessage.termsNotAccepted);
    if (!childInfoViewModel.isFormValid) return _reject(AppMessage.childInfoMissing);
    return null;
  }

  Future<AuthResult> _run(AuthMethod method, Future<AuthResult> Function() action) async {
    if (isLoading) return const AuthCancelled(); // abaikan ketukan ganda
    _activeMethod = method;
    error = null;
    notifyListeners();
    try {
      final result = await action();
      if (result is AuthFailed) _setError(result.message);
      return result;
    } finally {
      _activeMethod = null;
      notifyListeners();
    }
  }

  AuthResult _reject(AppMessage message) {
    _setError(message);
    return AuthFailed(message, AuthFailureReason.invalidInput);
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
