import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:audioplayers/audioplayers.dart';

class StoryViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _storyText = "Choose category and sentiment to start the story!";
  String get storyText => _storyText;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  Future<void> generateAndPlayStory(String category, String sentiment) async {
    _isLoading = true;
    notifyListeners();

    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? "";
      final url = Uri.parse('$baseUrl/generate-story');

      final response = await http.post(
        url,
        headers: {'Content-type': 'application/json'},
        body: jsonEncode({
          "category": category,
          "sentiment": sentiment,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _storyText = data['story'];

        final audioUrl = data ['audio_url'];
        await _audioPlayer.play(UrlSource(audioUrl));
        _isPlaying = true;
      } else {
        _storyText = "Failed to create a story on the AI server";
      }
    } catch (e) {
      _storyText = "Ensure the FastAPI server is running. Error: $e";
    } finally {
      _isLoading = true;
      notifyListeners();
    }
  }

  void togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.pause();
    }

    _isPlaying = !_isPlaying;
    notifyListeners();
  }
}