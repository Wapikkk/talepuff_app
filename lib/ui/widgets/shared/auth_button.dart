import 'package:flutter/material.dart';
import '../../../core/app_assets.dart';

class AuthButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final bool isBusy;
  final bool showSpinner;
  final VoidCallback onPressed;

  const AuthButton({
    super.key,
    required this.label,
    required this.background,
    this.foreground = Colors.white,
    required this.isBusy,
    required this.showSpinner,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isBusy ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: background,
          disabledBackgroundColor: background.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: showSpinner
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 3, color: foreground),
              )
            : Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: AppAssets.fontFamily,
                ),
              ),
      ),
    );
  }
}
