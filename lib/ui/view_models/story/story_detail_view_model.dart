import 'package:flutter/material.dart';

import '../../../data/models/account_result.dart';
import '../../../data/models/app_message.dart';
import '../../../data/models/story.dart';
import '../../../data/repositories/story_repository.dart';

class StoryDetailViewModel extends ChangeNotifier {
  StoryDetailViewModel({required StoryRepository repository}) : _repository = repository;

  final StoryRepository _repository;

  StoryDetail? story;
  bool isLoading = true;
  AppMessage? error;

  bool favoriteChanged = false;

  bool _isSaving = false;
  bool _disposed = false;

  Future<void> load(int id) async {
    isLoading = true;
    error = null;
    _notify();

    final result = await _repository.get(id);
    if (_disposed) return;

    isLoading = false;
    switch (result) {
      case StoryDetailLoaded(story: final loaded):
        story = loaded;
      case StoryDetailFailed(:final message):
        error = message;
    }
    _notify();
  }

  Future<AccountResult?> toggleFavorite() async {
    final current = story;
    if (current == null || _isSaving) return null;

    _isSaving = true;
    final wanted = !current.isFavorite;
    story = current.copyWith(isFavorite: wanted);
    _notify();

    final result = await _repository.setFavorite(current.id, wanted);
    _isSaving = false;
    if (_disposed) return result;

    if (result is AccountFailure) {
      story = current;
    } else {
      favoriteChanged = true;
    }
    _notify();
    return result;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
