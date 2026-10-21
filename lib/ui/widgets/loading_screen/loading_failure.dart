import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_assets.dart';
import 'package:talepuff_app/core/app_colors.dart';

class LoadingFailure extends StatelessWidget {
  final String message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;

  const LoadingFailure({
    super.key,
    required this.message,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
                height: 1.4,
                fontFamily: AppAssets.fontFamily,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _PillButton(
                    key: const Key('failure-secondary'),
                    label: secondaryLabel,
                    background: Colors.white,
                    foreground: AppColors.gradient4,
                    bordered: true,
                    onPressed: onSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PillButton(
                    key: const Key('failure-primary'),
                    label: primaryLabel,
                    background: AppColors.gradient4,
                    foreground: Colors.white,
                    onPressed: onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;
  final bool bordered;
  final VoidCallback onPressed;

  const _PillButton({
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
            side: bordered ? const BorderSide(color: AppColors.gradient4, width: 2) : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: FittedBox(
          fit: BoxFit.scaleDown,
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
      ),
    );
  }
}
