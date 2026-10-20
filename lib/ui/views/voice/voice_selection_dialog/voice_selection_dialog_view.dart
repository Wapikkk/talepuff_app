import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../view_models/voice/voice_result/voice_result_view_model.dart';
import '../../../view_models/voice/voice_selection_dialog/voice_selection_dialog_view_model.dart';
import '../../../widgets/voice/voice_selection_dialog/voice_dialog_container.dart';
import '../../../widgets/voice/voice_selection_dialog/voice_done_button.dart';
import '../../../widgets/voice/voice_selection_dialog/voice_option_button.dart';

class VoiceSelectionDialogView extends StatelessWidget {
  final int storyId;
  const VoiceSelectionDialogView({super.key, required this.storyId});

  static void show(BuildContext context, int storyId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => VoiceSelectionDialogView(storyId: storyId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !context.watch<VoiceResultViewModel>().isProcessingAudio,
      child: VoiceDialogContainer(
        title: "Choose your voice",
        child: Column(
          children: [
            Consumer<VoiceSelectionDialogViewModel>(
              builder: (context, viewModel, child) {
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: List.generate(viewModel.voiceOptions.length, (
                    index,
                  ) {
                    return VoiceOptionButton(
                      option: viewModel.voiceOptions[index],
                      isSelected: viewModel.isSelected(index),
                      onTap: () {
                        final voice = context.read<VoiceResultViewModel>();
                        if (voice.isProcessingAudio) return;
                        voice.clearError();
                        viewModel.selectVoice(index);
                      },
                    );
                  }),
                );
              },
            ),

            const SizedBox(height: 30),

            VoiceDoneButton(
              storyId: storyId,
              onPressed: () {
                final viewModel = context.read<VoiceSelectionDialogViewModel>();
                if (viewModel.selectedIndex != -1) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
