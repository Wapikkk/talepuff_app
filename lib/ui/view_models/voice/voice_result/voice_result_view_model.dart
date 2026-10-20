import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../voice_selection_dialog/voice_selection_dialog_view_model.dart';
import 'package:talepuff_app/data/services/mqtt_service.dart';

typedef AudioPublisher = Future<void> Function(String audioUrl);

class VoiceResultViewModel extends ChangeNotifier {
  VoiceResultViewModel({required http.Client client, AudioPublisher? publisher})
    : _client = client,
      _publish = publisher ?? ((url) => MqttService().publishAudioUrl(url));

  final http.Client _client;
  final AudioPublisher _publish;

  bool _isProcessingAudio = false;
  bool get isProcessingAudio => _isProcessingAudio;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> processAndSendAudio(
    VoiceOption selectedVoice,
    int storyId,
  ) async {
    if (_isProcessingAudio) return false;

    _isProcessingAudio = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final baseUrl =
          "${dotenv.env['API_BASE_URL'] ?? ''}/api/audio/generate_audio";

      final response = await _client.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'story_id': storyId,
          'voice_tone': selectedVoice.title,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint("Failed to create audio: ${response.body}");
        _errorMessage = "We couldn't create the voice. Please try again.";
        return false;
      }

      final audioUrl = jsonDecode(response.body)['audio_url'];
      debugPrint("Success! URL Audio: $audioUrl");

      try {
        await _publish(audioUrl);
      } catch (e) {
        debugPrint("The totem could not be reached: $e");
      }
      return true;
    } catch (e) {
      debugPrint("A connection error occurred: $e");
      _errorMessage =
          "Can't reach the server. Check your connection and try again.";
      return false;
    } finally {
      _isProcessingAudio = false;
      notifyListeners();
    }
  }
}
