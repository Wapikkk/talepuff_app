import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/core/app_assets.dart';
import 'package:talepuff_app/core/app_colors.dart';
import 'package:talepuff_app/ui/view_models/voice/voice_result/voice_result_view_model.dart';
import 'package:talepuff_app/ui/view_models/voice/voice_selection_dialog/voice_selection_dialog_view_model.dart';
import 'package:talepuff_app/ui/widgets/shared/top_banner.dart';

class VoiceDoneButton extends StatelessWidget {
  final VoidCallback onPressed;
  final int storyId;
  const VoiceDoneButton({
    super.key,
    required this.onPressed,
    required this.storyId,
  });

  Future<void> _submit(BuildContext context) async {
    final selectedVoice = context
        .read<VoiceSelectionDialogViewModel>()
        .getSelectedVoice();
    if (selectedVoice == null) return;

    final overlay = TopBanner.overlayOf(context);
    final navigator = Navigator.of(context);
    final created = await context
        .read<VoiceResultViewModel>()
        .processAndSendAudio(selectedVoice, storyId);

    if (!created) return;
    navigator.pop();
    TopBanner.show(overlay, "Your story voice is ready");
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<VoiceResultViewModel>();
    final busy = viewModel.isProcessingAudio;
    final error = viewModel.errorMessage;

    return Column(
      children: [
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontFamily: AppAssets.fontFamily,
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gradient4,
              disabledBackgroundColor: AppColors.gradient4.withValues(
                alpha: 0.6,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: busy ? null : () => _submit(context),
            child: busy
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          "Creating the voice…",
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppAssets.fontFamily,
                          ),
                        ),
                      ),
                    ],
                  )
                : const Text(
                    "Done",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppAssets.fontFamily,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
