import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewModel extends ChangeNotifier{
  String email = '';
  String password = '';
  bool rememberMe = false;
  String? errorMessage;
  bool isLoading = false;
  bool _isPasswordObscured = true;
  bool get isPasswordObscured => _isPasswordObscured;

  Future<void> loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');
    if (savedEmail != null) {
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

  Future<void> login(BuildContext context) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      _setErrorMessage("Email and Password are required!");
      return;
    }

    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      _setErrorMessage("Invalid email format, please check again!");
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setString('saved_email', email.trim());
      } else {
        await prefs.remove('saved_email');
      }

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/main_nav');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        _setErrorMessage("Incorrect Email and Password, Please Try Again!");
      } else {
        _setErrorMessage(e.message ?? "An error occurred during login");
      }
    } catch (e) {
      _setErrorMessage("An unexpected error occurred");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _setErrorMessage(String message) {
    errorMessage = message;
    notifyListeners();
    Future.delayed(const Duration(seconds: 3), () {
      errorMessage = null;
      notifyListeners();
    });
  }
}