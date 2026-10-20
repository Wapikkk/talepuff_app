import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_assets.dart';

class UpdateBtnSettings extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isBusy;
  final bool enabled;

  const UpdateBtnSettings({
    super.key,
    required this.text,
    required this.onPressed,
    this.isBusy = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.btnSave,
          disabledBackgroundColor: isBusy ? AppColors.btnSave.withValues(alpha: 0.6) : const Color(0xFFBDBDBD),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 2,
        ),
        onPressed: (isBusy || !enabled) ? null : onPressed,
        child: isBusy
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
              )
            : Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppAssets.fontFamily,
                ),
              ),
      ),
    );
  }
}
