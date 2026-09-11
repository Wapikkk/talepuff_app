import 'package:flutter/material.dart';
import '../voice_selection_dialog/voice_selection_dialog_view_model.dart';

class VoiceResultViewModel extends ChangeNotifier{
  bool _isProcessingAudio = false;
  bool get isProcessingAudio => _isProcessingAudio;

  Future<void> processAndSendAudio(VoiceOption selectedVoice, String storyText) async {
    _isProcessingAudio = true;
    notifyListeners();

    try {
      // 1. Call API Text-to-Speech here based on selectedVoice.title
      // await ttsService.generateAudio(storyText, selectedVoice.title);

      // 2. Send data/URL audio to Microcontroller (via MQTT/HTTP/WebSocket)
      // await hardwareService.sendToDevice(audioPayload);

      // Simulated delay proses
      await Future.delayed(const Duration(seconds: 3));

    } catch (e) {
      // Handle error connection/hardware
    } finally {
      _isProcessingAudio = false;
      notifyListeners();
    }
  }
}