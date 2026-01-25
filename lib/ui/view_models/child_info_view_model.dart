import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_assets.dart';
import '../../data/services/auth_service.dart';

class ChildInfoViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  String _childName = "Friend";
  String get childName => name.trim().isNotEmpty ? name : _childName;
  String name = '';
  String? errorMessage;
  String age = '';
  String selectedGender = '';
  List<String> selectedInterests = [];

  final List<Map<String, String>> allInterestData = [
    {'name': 'Sports', 'icon': AppAssets.iconSports},
    {'name': 'Music', 'icon': AppAssets.iconMusicNote},
    {'name': 'Art', 'icon': AppAssets.iconArt},
    {'name': 'Science', 'icon': AppAssets.iconScience},
    {'name': 'Nature', 'icon': AppAssets.iconNature},
    {'name': 'Space', 'icon': AppAssets.iconSpace},
    {'name': 'Magic', 'icon': AppAssets.iconMagic},
    {'name': 'Reading', 'icon': AppAssets.iconReading},
    {'name': 'Dancing', 'icon': AppAssets.iconDancing},
    {'name': 'Games', 'icon': AppAssets.iconGames},
  ];

  bool get isFormValid {
    return name.trim().isNotEmpty && selectedGender.isNotEmpty && selectedInterests.isNotEmpty;
  }

  void updateName(String value) {
    name = value;
    if (errorMessage != null) errorMessage = null;
    notifyListeners();
  }

  void updateGender(String gender) {
    selectedGender = gender;
    notifyListeners();
  }

  void toggleInterest(String interestName) {
    if (selectedInterests.contains(interestName)) {
      selectedInterests.remove(interestName);
    } else if (selectedInterests.length < 3) {
      selectedInterests.add(interestName);
    }
    notifyListeners();
  }

  void saveInfo(BuildContext context) {
    if (isFormValid) {
      Navigator.pushNamed(context, '/signup');
    } else {
      errorMessage = "Please fill in all mandatory fields!";
      notifyListeners();

      Future.delayed(const Duration(seconds: 3), () {
        errorMessage = null;
        notifyListeners();
      });
    }
  }

  Future<void> syncChildData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final data = await _authService.getChildInfo(user.uid);
      if (data != null && data['name'] != null) {
        _childName = data['name'];
        notifyListeners();
      }
    }
  }
}