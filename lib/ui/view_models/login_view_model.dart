import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../data/services/auth_service.dart';
import '../../../ui/view_models/parent_view_model.dart';

class LoginViewModel extends ChangeNotifier{
  final AuthService _authService = AuthService();
  String? _currentChildId, _currentPhotoUrl, _childName, errorMessage;
  String? get currentChildId => _currentChildId; get currentPhotoUrl => _currentPhotoUrl; get childName => _childName;
  String email = '', password = '';
  bool rememberMe = false, isLoading = false, _isPasswordObscured = true;
  bool get isPasswordObscured => _isPasswordObscured;

  Future<void> loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');

    debugPrint("DEBUG VM: Email yang ditemukan di SharedPreferences: '$savedEmail'");

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

      if(!context.mounted) return;
      await _handleSuccessfulLogin(context);

    } on FirebaseAuthException catch (e) {

      if (e.code == 'user-not-found') {
        _setErrorMessage("Don't have an account, please sign up first!");
      } else {
        _setErrorMessage("Incorrect Email and Password, Please Try Again!");
      }

    } catch (e) {
      debugPrint("ERROR SISTEM: $e");
      if(!context.mounted) return;
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

    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      await prefs.setString('saved_email', email.trim());
      debugPrint("DEBUG: BERHASIL SIMPAN ke prefs: ${email.trim()}");
    } else {
      await prefs.remove('saved_email');
    }

    final childData = await _authService.getChildInfo(user.uid);
    if (childData == null) {
      _setErrorMessage("Please fill child's information first");
      return;
    }

    _currentChildId = childData['ID']?.toString() ?? childData['id']?.toString();
    _currentPhotoUrl = childData['profile_photo_url'];
    _childName = childData['name'];
    notifyListeners();

    if (context.mounted) {
      Provider.of<ParentViewModel>(context, listen: false)
        .setInitiateData(_currentChildId, _currentPhotoUrl, _childName);
      Navigator.pushReplacementNamed(context, '/main_nav');
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      _currentChildId = null;
      _currentPhotoUrl = null;
      email = '';
      password = '';
      rememberMe = false;
      notifyListeners();

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e) {
      debugPrint("Error saat logout: $e");
    }
  }
}