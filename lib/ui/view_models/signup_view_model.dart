import 'package:flutter/material.dart';

class SignUpViewModel extends ChangeNotifier {
  String email = '';
  String password = '';
  bool isAccepted = false;

  void updateEmail(String value) {
    email = value;
    notifyListeners();
  }

  void updatePassword(String value) {
    password = value;
    notifyListeners();
  }

  void toggleAccepted(bool value) {
    isAccepted = value;
    notifyListeners();
  }
}