import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../views/voice/voice_result/voice_result_view.dart';

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
      final baseUrl = '${dotenv.env['API_BASE_URL'] ?? ''}/api/story/generate';
      debugPrint("Starting process AI to: $baseUrl");

      final user = FirebaseAuth.instance.currentUser;
      final token = await user?.getIdToken(true);

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(payload),
      );

      if(response.statusCode == 200 || response.statusCode == 201){
        final resultData = jsonDecode(response.body);
        debugPrint("The story was successfully created!");

        _simulatedTimer?.cancel();
        _progress = 1.0;
        notifyListeners();

        await Future.delayed(const Duration(milliseconds: 500));

        if(!context.mounted) return;

        final storyData = resultData['data'] ?? {};

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VoiceResultView(
              title: storyData['title'] ?? 'Story Title',
              generatedText: storyData['content'] ?? 'Story text not available',
              imageUrl: storyData['image_url'] ?? '',
              payload: payload,
              storyId: storyData['id'] ?? 0,
            ),
          ),
        );
      } else {
        throw Exception("Status server response: ${response.statusCode}");
      }
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