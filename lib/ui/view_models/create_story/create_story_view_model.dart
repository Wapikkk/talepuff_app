import 'package:flutter/material.dart';
import 'package:talepuff_app/core/story_defaults.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talepuff_app/ui/views/loading_screen/loading_screen_view.dart';

class CreateStoryViewModel extends ChangeNotifier {
  String _selectedCategory = '';
  String _characterName = '';
  String _storyLength = '';
  final List<String> _selectedMoods = [];
  String _description = '';
  bool _isLoading = false;
  int _formVersion = 0;

  String get selectedCategory => _selectedCategory;
  String get characterName => _characterName;
  String get storyLength => _storyLength;
  List<String> get selectedMoods => _selectedMoods;
  String get description => _description;
  bool get isLoading => _isLoading;
  int get formVersion => _formVersion;

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

  void setDescription(String desc) {
    _description = desc;
  }

  void reset() {
    _selectedCategory = '';
    _characterName = '';
    _storyLength = '';
    _selectedMoods.clear();
    _description = '';
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
    };
  }

  Future<void> generateStory(BuildContext context) async {
    if (_selectedCategory.isEmpty ||
        _characterName.isEmpty ||
        _storyLength.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill the required fields (Category, Name, Length)",
          ),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final activeChild = prefs.getInt('active_child_id');
    if (activeChild == null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error: No active child profile found.")),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final payload = buildPayload(childId: activeChild);
      debugPrint("Payload ready! move to Loading Screen...");
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                LoadingScreenView(payload: payload, onCreated: reset),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error generating story: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
