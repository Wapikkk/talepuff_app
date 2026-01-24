import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/services/auth_service.dart';

class HomeViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String _activeMascot = 'Harimau';

  bool get isLoading => _isLoading;
  String get activeMascot => _activeMascot;

  Future<void> prepareHomeData() async {
    _isLoading = true;
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final data = await _authService.getChildInfo(user.uid);
      if (data != null) {
        _activeMascot = data['mascot_id'] ?? 'Harimau';
      }
    }

    _isLoading = false;
    notifyListeners();
  }
}