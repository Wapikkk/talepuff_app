import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../data/models/auth_result.dart';
import '../../../data/repositories/auth_repository.dart';

/// Logika layar login, sekaligus pemegang data sesi yang dibaca layar lain
/// (`currentChildId`, `currentPhotoUrl`, `childName`, `email`) lewat [applySession].
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({required AuthRepository repository}) : _repository = repository;

  static const savedEmailKey = 'saved_email';

  final AuthRepository _repository;
  Timer? _errorTimer;

  String? _currentChildId, _currentPhotoUrl, _childName;
  String? get currentChildId => _currentChildId;
  String? get currentPhotoUrl => _currentPhotoUrl;
  String? get childName => _childName;

  String? errorMessage;
  String email = '', password = '';
  bool rememberMe = false;
  bool _isPasswordObscured = true;
  bool get isPasswordObscured => _isPasswordObscured;

  AuthMethod? _activeMethod;
  AuthMethod? get activeMethod => _activeMethod;
  bool get isLoading => _activeMethod != null;

  Future<void> loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString(savedEmailKey);
    if (savedEmail != null && savedEmail.isNotEmpty) {
      email = savedEmail;
      rememberMe = true;
      notifyListeners();
    }
  }

  void updateEmail(String value) {
    email = value;
    if (errorMessage != null) errorMessage = null;
    notifyListeners();
  }

  void updatePassword(String value) {
    password = value;
    if (errorMessage != null) errorMessage = null;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordObscured = !_isPasswordObscured;
    notifyListeners();
  }

  void toggleRememberMe(bool value) {
    rememberMe = value;
    notifyListeners();
  }

  Future<AuthResult> login() async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      return _reject('Email and Password are required!');
    }
    final emailError = _emailError(email);
    if (emailError != null) return _reject(emailError);

    return _run(AuthMethod.email, () => _repository.signInWithEmail(email.trim(), password.trim()),
        remember: true);
  }

  Future<AuthResult> loginWithGoogle() => _run(AuthMethod.google, _repository.continueWithGoogle);

  /// Mengisi data sesi setelah masuk berhasil.
  void applySession(SignedIn session) {
    _currentChildId = session.profile.id.toString();
    _currentPhotoUrl = session.profile.photoUrl;
    _childName = session.profile.name;
    if (session.email != null) email = session.email!;
    password = '';
    notifyListeners();
  }

  Future<void> logout() async {
    await _repository.signOut();
    _currentChildId = null;
    _currentPhotoUrl = null;
    _childName = null;
    email = '';
    password = '';
    rememberMe = false;
    errorMessage = null;
    notifyListeners();
  }

  // ---------- internal ----------

  String? _emailError(String value) {
    // Pemeriksaan format yang sama dengan pendaftaran, tanpa aturan kata sandi
    // (kata sandi lama tetap boleh dipakai untuk masuk).
    return RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(value.trim())
        ? null
        : 'Invalid email format, please check again!';
  }

  Future<AuthResult> _run(
    AuthMethod method,
    Future<AuthResult> Function() action, {
    bool remember = false,
  }) async {
    if (isLoading) return const AuthCancelled(); // abaikan ketukan ganda
    _activeMethod = method;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await action();
      if (result is AuthFailed) _setErrorMessage(result.message);
      if (remember && (result is SignedIn || result is NeedsProfile)) await _persistEmail();
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

  Future<void> _persistEmail() async {
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString(savedEmailKey, email.trim());
    } else {
      await prefs.remove(savedEmailKey);
    }
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
