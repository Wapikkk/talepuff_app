import 'dart:async';
import 'package:flutter/material.dart';

class LoadingViewModel extends ChangeNotifier {
  double _progress = 0.0;
  double get progress => _progress;

  String _timeRemaining = "remaining 3 minutes";
  String get timeRemaining => _timeRemaining;

  Timer? _simulatedTimer;

  int _currentMascotIndex = 0;
  int get currentMascotIndex => _currentMascotIndex;

  Timer? _sliderTimer;

  void startGeneratingStory(BuildContext context, Map<String, dynamic> payload) {
    _startSimulatedProgress();
    _callBackendAPI(context, payload);
  }

  void _startSimulatedProgress() {
    _progress = 0.0;

    _simulatedTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_progress < 0.9) {
        _progress += 0.01;

        if (_progress > 0.6) {
          _timeRemaining = "remain 1 minute";
        } else if (_progress > 0.3){
          _timeRemaining = "remain 2 minutes";
        }
        notifyListeners();
      }
    });
  }

  void startAutoplay(PageController controller, int itemCount) {
    _sliderTimer?.cancel();
    _sliderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (controller.hasClients) {
        int nextIndex = (_currentMascotIndex + 1) % itemCount;
        controller.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  void updateMascotIndex(int index) {
    _currentMascotIndex = index;
    notifyListeners();
  }

  Future<void> _callBackendAPI(BuildContext context, Map<String, dynamic> payload) async {
    try {
    //   TODO Uncomment this line after StoryService ready
    //   final result = await StoryService().generateStory(payload);

      await Future.delayed(const Duration(seconds: 5));

      _simulatedTimer?.cancel();
      _progress = 1.0;
      notifyListeners();

      await Future.delayed(const Duration(milliseconds: 500));

      if(!context.mounted) return;
    //   TODO Navigate to voice page
    //   Navigator.pushReplacementNamed(context, '/story_result', argument: result)

    } catch (e) {
      _simulatedTimer?.cancel();
      if(!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to generate story: $e")),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _simulatedTimer?.cancel();
    _sliderTimer?.cancel();
    super.dispose();
  }
}