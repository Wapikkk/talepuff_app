import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_colors.dart';
import 'package:talepuff_app/core/app_assets.dart';

class ReGenerateButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ReGenerateButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: const BoxDecoration(
          color: AppColors.gradient4,
          borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
        ),
        child: TextButton(
          onPressed: onPressed,
          child: const Text(
            "Re-Generate",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              fontFamily: AppAssets.fontFamily,
            ),
          ),
        ),
      ),
    );
  }
}