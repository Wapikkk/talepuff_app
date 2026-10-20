import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/app_assets.dart';
import '../../../core/mascots.dart';
import '../../../core/validators.dart';
import '../../../data/models/auth_result.dart';
import '../../../data/models/child_profile.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/services/auth_service.dart';

class ChildInfoViewModel extends ChangeNotifier {
  ChildInfoViewModel({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;
  Timer? _errorTimer;

  String _childName = "Friend", name = '', age = '', selectedGender = '';
  String _mascotId = Mascots.defaultId;
  String get mascotId => _mascotId;
  String get childName => name.trim().isNotEmpty ? name.trim() : _childName;
  String? errorMessage;
  bool isLoading = false;
  final List<String> _selectedInterests = [];
  List<String> get selectedInterests => _selectedInterests;

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

  int? get ageValue {
    final value = int.tryParse(age.trim());
    return (value != null && value > 0) ? value : null;
  }

  String? get ageError =>
      (age.trim().isEmpty || ageValue != null) ? null : 'Please enter a valid age.';

  bool get _hasMandatoryFields =>
      name.trim().isNotEmpty && selectedGender.isNotEmpty && selectedInterests.isNotEmpty;

  String? get nameError => name.trim().isEmpty ? null : AuthValidators.childName(name);

  bool get isFormValid => _hasMandatoryFields && nameError == null && ageError == null;

  ChildDraft toDraft() => ChildDraft(
        name: name.trim(),
        age: ageValue,
        gender: selectedGender,
        interests: List.unmodifiable(selectedInterests),
      );

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
    if (_validate()) Navigator.pushNamed(context, '/signup');
  }

  Future<AuthResult?> completeProfile() async {
    if (isLoading || !_validate()) return null;
    isLoading = true;
    notifyListeners();
    try {
      final result = await _repository.completeProfile(toDraft());
      if (result is AuthFailed) _showError(result.message);
      return result;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void applySavedName(String newName) {
    _childName = newName.trim();
    name = '';
    notifyListeners();
  }

  void reset() {
    name = '';
    age = '';
    selectedGender = '';
    _selectedInterests.clear();
    _childName = "Friend";
    _mascotId = Mascots.defaultId;
    errorMessage = null;
    isLoading = false;
    notifyListeners();
  }

  void applyProfile(ChildProfile profile) {
    if (profile.name.isNotEmpty) _childName = profile.name;
    name = '';
    age = profile.age?.toString() ?? '';
    _selectedInterests
      ..clear()
      ..addAll(profile.interests);
    _mascotId = profile.mascotId;
    notifyListeners();
  }

  void applyMascot(String mascotId) {
    _mascotId = Mascots.isValid(mascotId) ? mascotId : Mascots.defaultId;
    notifyListeners();
  }

  Future<void> syncChildData() async {
    final lookup = await _repository.currentProfile();
    if (lookup is! ProfileFound) {
      debugPrint('[auth] syncChildData skipped: ${lookup.runtimeType}');
      return;
    }
    applyProfile(lookup.profile);
  }

  bool _validate() {
    if (isFormValid) return true;
    _showError(_hasMandatoryFields ? (nameError ?? ageError!) : 'Please fill in all mandatory fields!');
    return false;
  }

  void _showError(String message) {
    errorMessage = message;
    notifyListeners();
    _errorTimer?.cancel();
    _errorTimer = Timer(const Duration(seconds: 3), () {
      errorMessage = null;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    super.dispose();
  }
}
