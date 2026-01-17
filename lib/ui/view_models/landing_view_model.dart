import 'package:flutter/material.dart';
import 'dart:async';

class LandingViewModel extends ChangeNotifier{
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;
  bool _isForward = true;
  Timer? _timer;

  void updateIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void startAutoplay(PageController controller, int itemCount) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_isForward) {
        if (_currentIndex < itemCount - 1) {
          _currentIndex++;
        } else {
          _isForward = false;
          _currentIndex--;
        }
      } else {
        if (_currentIndex > 0) {
          _currentIndex--;
        } else {
          _isForward = true;
          _currentIndex++;
        }
      }

      if (controller.hasClients) {
        controller.animateToPage(
          _currentIndex,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutQuart,
        );
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}