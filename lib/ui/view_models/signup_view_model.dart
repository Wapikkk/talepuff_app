import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:talepuff_app/data/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:talepuff_app/ui/view_models/child_info_view_model.dart';

class SignUpViewModel extends ChangeNotifier {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService _authService = AuthService();
  final ChildInfoViewModel childInfoViewModel;

  SignUpViewModel({required this.childInfoViewModel});

  String email = '';
  String password = '';
  bool isAccepted = false;
  bool isLoading = false;
  String? errorMessage;
  bool _isPasswordObscured = true;
  bool get isPasswordObscured => _isPasswordObscured;

  void updateEmail(String value) {
    email = value;
    errorMessage = null;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    _isPasswordObscured = !_isPasswordObscured;
    notifyListeners();
  }

  void updatePassword(String value) {
    password = value;
    errorMessage = null;
    notifyListeners();
  }

  void toggleAccepted(bool value) {
    isAccepted = value;
    notifyListeners();
  }

  Future<void> signUpManual(BuildContext context) async{

    if (email.trim().isEmpty || password.trim().isEmpty) {
      _setErrorMessage("Email and Password are required!");
      return;
    }

    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      _setErrorMessage("Invalid email format, please check again!");
      return;
    }

    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');
    if (!passwordRegex.hasMatch(password)) {
      _setErrorMessage("Password must be at least 8 characters with letters and numbers!");
      return;
    }

    if (!isAccepted) {
      _setErrorMessage("Please accept our Terms and Conditions to continue.");
      return;
    }

    if (childInfoViewModel.childName.isEmpty || childInfoViewModel.childName == "Friend") {
      _setErrorMessage("Please fill child's information first");
      return;
    }

    try {
      isLoading = true;
      notifyListeners();

      await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      if (_auth.currentUser != null) {
        debugPrint("Firebase Sukses (via currentUser), lanjut ke Backend...");
        await _registerAndNavigate(_auth.currentUser!, context);
      }

    } on FirebaseAuthException catch (e) {

      if (e.code == 'email-already-in-use') {
        _setErrorMessage("This email is already registered. Please login.");
      } else {
        _setErrorMessage(e.message ?? "An error occurred during sign up");
      }

    } catch (e) {
      debugPrint("Terdeteksi bug sistem (Pigeon), mengecek status login...");

      if (_auth.currentUser != null) {
        debugPrint("User ditemukan di sistem, lanjut ke backend...");
        await _registerAndNavigate(_auth.currentUser!, context);
      } else {
        _setErrorMessage("Unexpected error: $e");
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUpWithGoogle(BuildContext context) async {
    try {
      isLoading = true;
      notifyListeners();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _registerAndNavigate(userCredential.user!, context);
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error: ${e.message}");
    } catch (e) {
      User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        await _registerAndNavigate(currentUser, context);
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _registerAndNavigate(User user, BuildContext context) async{
    try {
      await _authService.registerToBackend(
        firebaseUid: user.uid,
        email: user.email ?? "",
        childName: childInfoViewModel.childName,
        age: childInfoViewModel.age.isEmpty ? null : int.tryParse(childInfoViewModel.age),
        gender: childInfoViewModel.selectedGender,
        interests: childInfoViewModel.selectedInterests,
      );

      if (!context.mounted) return;
      Navigator.pushReplacementNamed(context, '/main_nav');
    } catch (e) {
      debugPrint("Backend Error: $e");
      _setErrorMessage("Account created, but server sync failed. Please check your connection.");
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