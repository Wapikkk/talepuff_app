import 'package:flutter/material.dart';

class StoryFilterViewModel extends ChangeNotifier{
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedTab = "Recent";
  bool _isSearching = false;

  String get selectedTab => _selectedTab;
  bool get isSearching => _isSearching;
  FocusNode get searchFocusNode => _searchFocusNode;

  void setTab(String tab) {
    _selectedTab = tab;
    notifyListeners();
    // TODO: Fetch data function from this Repository
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