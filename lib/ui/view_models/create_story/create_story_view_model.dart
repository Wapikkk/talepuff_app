import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CreateStoryViewModel extends ChangeNotifier {
  String _selectedCategory = '';
  String _characterName = '';
  String _storyLength = '';
  final List<String> _selectedMoods = [];
  String _language = '';
  String _description = '';
  bool _isLoading = false;

  String get selectedCategory => _selectedCategory;
  String get characterName => _characterName;
  String get storyLength => _storyLength;
  List<String> get selectedMoods => _selectedMoods;
  String get language => _language;
  String get description => _description;
  bool get isLoading => _isLoading;

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setCharacterName(String name) {
    _characterName = name;
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

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void setDescription(String desc) {
    _description = desc;
  }

  Future<void> generateStory(BuildContext context) async {
    if (_selectedCategory.isEmpty || _characterName.isEmpty || _storyLength.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill the required fields (Category, Name, Length)")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final activeChild = prefs.getInt('active_child_id');
    if (activeChild == null) {
      if(!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: No active child profile found.")),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      int lengthMinutes = int.tryParse(_storyLength.split(' ') [0]) ?? 3;
      String moodString = _selectedMoods.join(", ");
      final payload = {
        "child_id": activeChild,
        "character_name": _characterName,
        "theme": _selectedCategory,
        "mood": moodString,
        "length_minutes": lengthMinutes,
        "language": _language,
        "description": _description,
      };

      debugPrint("Sending Payload to Backend: $payload");

      // TODO: Call AuthService/StoryService in here to hit API Backend
      await Future.delayed(const Duration(seconds: 2));

    } catch (e) {
      debugPrint("Error generating story: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}