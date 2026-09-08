import 'package:flutter/material.dart';

class StoryFilterViewModel extends ChangeNotifier{
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedTab = "Recent";
  bool _isSearching = false;
  List<String> _stories = [];

  String get selectedTab => _selectedTab;
  bool get isSearching => _isSearching;
  FocusNode get searchFocusNode => _searchFocusNode;
  List<String> get stories => _stories;

  StoryFilterViewModel() {
    _fetchStoriesForTab(_selectedTab);
  }

  void setTab(String tab) {
    _selectedTab = tab;
    _fetchStoriesForTab(tab);
    notifyListeners();
    // TODO: Fetch data function from this Repository
  }

  Future<void> _fetchStoriesForTab(String tab) async {
    // TODO: Change this block with request http GET to backend

    if (tab == "Popular") {
      _stories = ["The Sleeping Cloud", "Aira's Brave Journey", "Light in The Forest", "Magic Tree"];
    } else {
      _stories = [];
    }
    notifyListeners();
  }

  void toggleSearch(bool status) {
    _isSearching = status;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }
}