import 'package:flutter/material.dart';

class NavbarViewModel extends ChangeNotifier {
  int _currentIndex = 0; get currentIndex => _currentIndex;

  void changeIndex (int index) {
    _currentIndex = index;
    notifyListeners();
  }
}