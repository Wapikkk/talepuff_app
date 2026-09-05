import 'package:flutter/material.dart';

class StoryViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _storyText = "";
  String get storyText => _storyText;

  Future<void> generateStory(String category, String sentiment) async {
    _isLoading = true;
    notifyListeners();

    // TODO: Input logic HTTP Request to FastAPI and Audio Player in here
    await Future.delayed(const Duration(seconds: 2));
    _storyText = "Stories about $category with a $sentiment vibe will appear here.";

    _isLoading = false;
    notifyListeners();
  }
}