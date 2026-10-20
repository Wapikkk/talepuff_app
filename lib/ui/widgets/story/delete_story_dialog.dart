import 'package:flutter/material.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../voice/voice_selection_dialog/voice_dialog_container.dart';

class DeleteStoryDialog extends StatelessWidget {
  final String storyTitle;

  const DeleteStoryDialog({super.key, required this.storyTitle});

  static Future<bool> confirm(BuildContext context, String storyTitle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => DeleteStoryDialog(storyTitle: storyTitle),
    );
    return confirmed == true;
  }

  @override
  Widget build(BuildContext context) {
    return VoiceDialogContainer(
      title: 'Delete this story?',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '"$storyTitle" and its voice will be removed. This can\'t be undone.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
              color: AppColors.darkPurple,
              fontFamily: AppAssets.fontFamily,
            ),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              Expanded(
                child: _DialogButton(
                  key: const Key('cancel-delete'),
                  label: 'Cancel',
                  background: Colors.white,
                  foreground: AppColors.gradient4,
                  bordered: true,
                  onPressed: () => Navigator.pop(context, false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DialogButton(
                  key: const Key('confirm-delete'),
                  label: 'Delete',
                  background: AppColors.logout,
                  foreground: Colors.white,
                  onPressed: () => Navigator.pop(context, true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final bool bordered;
  final VoidCallback onPressed;

  const _DialogButton({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
    this.bordered = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          elevation: bordered ? 0 : null,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: bordered
                ? const BorderSide(color: AppColors.gradient4, width: 2)
                : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            color: foreground,
            fontWeight: FontWeight.bold,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
      ),
    );
  }
}
