import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/core/app_assets.dart';
import 'package:talepuff_app/core/app_colors.dart';
import 'package:talepuff_app/ui/view_models/voice/voice_result/voice_result_view_model.dart';
import 'package:talepuff_app/ui/view_models/voice/voice_selection_dialog/voice_selection_dialog_view_model.dart';

class VoiceDoneButton extends StatelessWidget{
  final VoidCallback onPressed;
  final int storyId;
  const VoiceDoneButton({super.key, required this.onPressed, required this.storyId});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gradient4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        onPressed: () async {
          final selectedVoice = context.read<VoiceSelectionDialogViewModel>().getSelectedVoice();

          if (selectedVoice == null) {
            debugPrint("Choose voice tone first!");
            return;
          }

          await context.read<VoiceResultViewModel>().processAndSendAudio(
            selectedVoice,
            storyId,
          );

          if (context.mounted) {
            Navigator.pop(context);
          }
        },
        child: const Text(
          "Done",
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
      ),
    );
  }
}