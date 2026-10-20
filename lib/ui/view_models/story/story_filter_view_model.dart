import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/account_result.dart';
import '../../../data/models/story.dart';
import '../../../data/repositories/story_repository.dart';

class StoryFilterViewModel extends ChangeNotifier {
  StoryFilterViewModel({
    required StoryRepository repository,
    required String? Function() childId,
    Duration searchDelay = const Duration(milliseconds: 350),
  }) : _repository = repository,
       _childId = childId,
       _searchDelay = searchDelay;

  final StoryRepository _repository;
  final String? Function() _childId;
  final Duration _searchDelay;
  final FocusNode _searchFocusNode = FocusNode();

  StoryTab _tab = StoryTab.recent;
  List<StorySummary> _stories = const [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  bool _isSearching = false;
  String _query = '';
  String? errorMessage;

  final Set<int> _deleting = {};
  int _request = 0;
  Timer? _debounce;
  bool _disposed = false;

  StoryTab get tab => _tab;
  List<StorySummary> get stories => _stories;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  bool get isSearching => _isSearching;
  String get query => _query;
  FocusNode get searchFocusNode => _searchFocusNode;

  bool isDeleting(int id) => _deleting.contains(id);

  Future<void> load() async {
    final childId = int.tryParse(_childId() ?? '');
    if (childId == null) {
      errorMessage =
          "Child's data has not been loaded yet. Please try again in a moment.";
      _isLoading = false;
      _notify();
      return;
    }

    final request = ++_request;
    _isLoading = true;
    _isLoadingMore = false;
    errorMessage = null;
    _notify();

    final result = await _repository.list(
      childId: childId,
      tab: _tab,
      query: _query,
    );
    if (request != _request || _disposed) return;

    _isLoading = false;
    switch (result) {
      case StoryListLoaded(:final stories, :final hasMore):
        _stories = stories;
        _hasMore = hasMore;
      case StoryListFailed(:final message):
        errorMessage = message;
    }
    _notify();
  }

  Future<void> setTab(StoryTab tab) async {
    if (tab == _tab) return;
    _tab = tab;
    _stories = const [];
    _hasMore = false;
    await load();
  }

  void search(String text) {
    _query = text.trim();
    _debounce?.cancel();
    _debounce = Timer(_searchDelay, load);
  }

  void toggleSearch(bool status) {
    _isSearching = status;
    final hadQuery = _query.isNotEmpty;
    if (!status) {
      _debounce?.cancel();
      _query = '';
    }
    _notify();
    if (!status && hadQuery) load();
  }

  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !_hasMore) return;
    final childId = int.tryParse(_childId() ?? '');
    if (childId == null) return;

    final request = _request;
    _isLoadingMore = true;
    _notify();

    final result = await _repository.list(
      childId: childId,
      tab: _tab,
      query: _query,
      offset: _stories.length,
    );
    if (request != _request || _disposed) return;

    _isLoadingMore = false;
    switch (result) {
      case StoryListLoaded(:final stories, :final hasMore):
        _stories = [..._stories, ...stories];
        _hasMore = hasMore;
      case StoryListFailed(:final message):
        errorMessage = message;
    }
    _notify();
  }

  Future<AccountResult?> toggleFavorite(StorySummary story) async {
    final index = _stories.indexWhere((item) => item.id == story.id);
    if (index < 0) return null;

    final wanted = !story.isFavorite;
    final updated = [..._stories];
    if (_tab == StoryTab.favorites && !wanted) {
      updated.removeAt(index);
    } else {
      updated[index] = story.copyWith(isFavorite: wanted);
    }
    _stories = updated;
    _notify();

    final result = await _repository.setFavorite(story.id, wanted);
    if (result is AccountFailure && !_disposed) {
      final rolledBack = [..._stories];
      final current = rolledBack.indexWhere((item) => item.id == story.id);
      if (current >= 0) {
        rolledBack[current] = story;
      } else {
        rolledBack.insert(index.clamp(0, rolledBack.length), story);
      }
      _stories = rolledBack;
      _notify();
    }
    return result;
  }

  Future<AccountResult?> deleteStory(StorySummary story) async {
    if (!_deleting.add(story.id)) return null;
    _notify();

    final result = await _repository.delete(story.id);
    _deleting.remove(story.id);
    if (result is AccountSuccess) {
      _stories = _stories.where((item) => item.id != story.id).toList();
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
    _debounce?.cancel();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
