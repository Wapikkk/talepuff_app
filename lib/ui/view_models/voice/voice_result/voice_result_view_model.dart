import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../voice_selection_dialog/voice_selection_dialog_view_model.dart';

class VoiceResultViewModel extends ChangeNotifier{
  bool _isProcessingAudio = false;
  bool get isProcessingAudio => _isProcessingAudio;

  Future<void> processAndSendAudio(VoiceOption selectedVoice, int storyId) async {
    _isProcessingAudio = true;
    notifyListeners();

    try {
      final baseUrl = "${dotenv.env['API_BASE_URL'] ?? ''}/generate_audio";

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-type': 'application/json'},
        body: jsonEncode({
          'story_id': storyId,
          'voice_tone': selectedVoice.title,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final audioUrl = data['audio_url'];

        debugPrint("Success! URL Audio: $audioUrl");

        // TODO: Send URL audio via MQTT / HTTP to Hardware
        // await hardwareService.sendToDevice(audioUrl);
      } else {
        debugPrint("Failed to create audio: ${response.body}");
        // TODO: Show alert fail to User
      }

    } catch (e) {
      debugPrint("A connection error occurred: $e");
    } finally {
      _isProcessingAudio = false;
      notifyListeners();
    }
  }
}