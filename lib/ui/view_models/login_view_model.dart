import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier{
  String email = '';
  String password = '';
  bool rememberMe = false;

  void updateEmail(String value) {
    email = value;
    notifyListeners();
  }

  void updatePassword(String value) {
    password = value;
    notifyListeners();
  }

  void toggleRememberMe(bool value) {
    rememberMe = value;
    notifyListeners();
  }

  void login(BuildContext context) {
    if (email.isNotEmpty && password.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/main_nav');
    } else {
      debugPrint("Form is incomplete or Terms are not checked");
    }
  }
}