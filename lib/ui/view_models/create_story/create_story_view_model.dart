import 'package:flutter/material.dart';
import 'package:talepuff_app/core/story_defaults.dart';
import 'package:talepuff_app/core/validators.dart';
import 'package:talepuff_app/data/models/app_message.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talepuff_app/ui/views/loading_screen/loading_screen_view.dart';

enum StoryField { category, length, voice }

class CreateStoryViewModel extends ChangeNotifier {
  String _selectedCategory = '';
  String _characterName = '';
  String _storyLength = '';
  final List<String> _selectedMoods = [];
  String _description = '';
  String _voiceTone = '';
  AppMessage? _error;
  AppMessage? _nameError;
  bool _isLoading = false;
  int _formVersion = 0;

  String get selectedCategory => _selectedCategory;
  String get characterName => _characterName;
  String get storyLength => _storyLength;
  List<String> get selectedMoods => _selectedMoods;
  String get description => _description;
  String get voiceTone => _voiceTone;
  AppMessage? get error => _error;
  AppMessage? get nameError => _nameError;
  bool get isLoading => _isLoading;
  int get formVersion => _formVersion;

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setCharacterName(String name) {
    _characterName = name;
    if (_nameError != null) {
      _nameError = null;
      notifyListeners();
    }
  }

  void setStoryLength(String length) {
    _storyLength = length;
    notifyListeners();
  }

  void toggleMood(String mood) {
    if (_selectedMoods.contains(mood)) {
      _selectedMoods.remove(mood);
    } else {
      _selectedMoods.add(mood);
    }
    notifyListeners();
  }

  void setVoiceTone(String voice) {
    _voiceTone = voice;
    _clearError();
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void setDescription(String desc) {
    _description = desc;
  }

  void reset() {
    _selectedCategory = '';
    _characterName = '';
    _storyLength = '';
    _selectedMoods.clear();
    _description = '';
    _voiceTone = '';
    _error = null;
    _nameError = null;
    _formVersion++;
    notifyListeners();
  }

  Map<String, dynamic> buildPayload({required int childId}) {
    return {
      "child_id": childId,
      "character_name": _characterName.trim(),
      "theme": _selectedCategory,
      "mood": _selectedMoods.join(", "),
      "length_minutes": int.tryParse(_storyLength.split(' ')[0]) ?? 3,
      "language": StoryDefaults.language,
      "description": _description.trim(),
      "voice_tone": _voiceTone,
    };
  }

  List<StoryField> missingFields() => [
        if (_selectedCategory.isEmpty) StoryField.category,
        if (_storyLength.isEmpty) StoryField.length,
        if (_voiceTone.isEmpty) StoryField.voice,
      ];

  Future<void> generateStory(BuildContext context) async {
    _nameError = AuthValidators.characterNameIssue(_characterName);
    final missing = missingFields();
    if (missing.isNotEmpty) {
      _error = AppMessage.chooseMissing;
    }
    if (_nameError != null || missing.isNotEmpty) {
      if (missing.isEmpty) _error = null;
      notifyListeners();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final activeChild = prefs.getInt('active_child_id');
    if (activeChild == null) {
      _error = AppMessage.childProfileMissing;
      notifyListeners();
      return;
    }

    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      final payload = buildPayload(childId: activeChild);
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoadingScreenView(payload: payload, onCreated: reset),
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
