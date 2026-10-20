import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/validators.dart';
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
  String? errorMessage;
  bool _isPasswordObscured = true;
  bool get isPasswordObscured => _isPasswordObscured;

  AuthMethod? _activeMethod;
  AuthMethod? get activeMethod => _activeMethod;
  bool get isLoading => _activeMethod != null;

  void updateEmail(String value) {
    email = value;
    errorMessage = null;
    notifyListeners();
  }

  void updatePassword(String value) {
    password = value;
    errorMessage = null;
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
    final emailError = AuthValidators.email(email);
    if (emailError != null) return _reject(emailError);

    final passwordError = AuthValidators.newPassword(password);
    if (passwordError != null) return _reject(passwordError);

    final precondition = _commonPreconditions();
    if (precondition != null) return precondition;

    return _run(
      AuthMethod.email,
      () => _repository.signUpWithEmail(email.trim(), password.trim(), childInfoViewModel.toDraft()),
    );
  }

  /// Daftar dengan Google. Akun yang sudah terdaftar ditolak (pengguna diarahkan ke Login).
  Future<AuthResult> signUpWithGoogle() async {
    final precondition = _commonPreconditions();
    if (precondition != null) return precondition;

    return _run(
      AuthMethod.google,
      () => _repository.signUpWithGoogle(childInfoViewModel.toDraft()),
    );
  }

  // ---------- internal ----------

  AuthResult? _commonPreconditions() {
    if (!isAccepted) return _reject('Please accept our Terms and Conditions to continue.');
    if (!childInfoViewModel.isFormValid) return _reject("Please fill child's information first");
    return null;
  }

  Future<AuthResult> _run(AuthMethod method, Future<AuthResult> Function() action) async {
    if (isLoading) return const AuthCancelled(); // abaikan ketukan ganda
    _activeMethod = method;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await action();
      if (result is AuthFailed) _setErrorMessage(result.message);
      return result;
    } finally {
      _activeMethod = null;
      notifyListeners();
    }
  }

  AuthResult _reject(String message) {
    _setErrorMessage(message);
    return AuthFailed(message, AuthFailureReason.invalidInput);
  }

  void _setErrorMessage(String message) {
    errorMessage = message;
    notifyListeners();
    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 3), () {
      errorMessage = null;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    super.dispose();
  }
}
