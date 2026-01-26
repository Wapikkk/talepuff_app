import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talepuff_app/data/services/auth_service.dart';

class LoginViewModel extends ChangeNotifier{
  final AuthService _authService = AuthService();
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

      await _handleSuccessfulLogin(context);

      final prefs = await SharedPreferences.getInstance();
      if (rememberMe) {
        await prefs.setString('saved_email', email.trim());
      } else {
        await prefs.remove('saved_email');
      }

    } on FirebaseAuthException catch (e) {

      if (e.code == 'user-not-found') {
        _setErrorMessage("Don't have an account, please sign up first!");
      } else {
        _setErrorMessage("Incorrect Email and Password, Please Try Again!");
      }

    } catch (e) {
      debugPrint("ERROR SISTEM: $e");
      if (FirebaseAuth.instance.currentUser != null) {
        debugPrint("User sukses login di background, melanjutkan ke backend...");
        await _handleSuccessfulLogin(context);
      } else {
        _setErrorMessage("An unexpected error occurred");
      }
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

  Future<void> _handleSuccessfulLogin(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final childData = await _authService.getChildInfo(user.uid);
    if (childData == null) {
      _setErrorMessage("Please fill child's information first");
      return;
    }

    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/main_nav');
    }
  }
}