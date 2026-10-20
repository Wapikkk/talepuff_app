import 'package:flutter/material.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/auth_service.dart';

class HomeViewModel extends ChangeNotifier {
  HomeViewModel({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;

  bool _isLoading = false;
  String _activeMascot = 'Harimau';

  bool get isLoading => _isLoading;
  String get activeMascot => _activeMascot;

  Future<void> prepareHomeData() async {
    _isLoading = true;
    notifyListeners();

    final lookup = await _repository.currentProfile();
    if (lookup is ProfileFound) {
      _activeMascot = lookup.raw['mascot_id']?.toString() ?? 'Harimau';
    }

    _isLoading = false;
    notifyListeners();
  }
}
