import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpViewModel extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  String email = '';
  String password = '';
  bool isAccepted = false;
  bool isLoading = false;
  bool _isPasswordObscured = true;
  bool get isPasswordObscured => _isPasswordObscured;

  void updateEmail(String value) {
    email = value;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordObscured = !_isPasswordObscured;
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

  void signUpManual(BuildContext context){
    if(email.isNotEmpty && password.isNotEmpty && isAccepted) {
      debugPrint("Trying Manual Sign-Up: $email");
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      debugPrint("Form is incomplete or Terms are not checked");
    }
  }

  Future<void> signUpWithGoogle(BuildContext context) async {
    try{
      isLoading = true;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (!context.mounted) return;

      if(googleUser != null) {
        debugPrint("Sign-Up Success: ${googleUser.email}");
        Navigator.pushReplacementNamed(context, '/main_nav');
      }
    } catch (error) {
      debugPrint("Error Google Sign-In: $error");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}