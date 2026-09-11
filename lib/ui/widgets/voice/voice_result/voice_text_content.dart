import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_assets.dart';
import 'package:talepuff_app/core/app_colors.dart';

class VoiceTextContent extends StatelessWidget {
  final String text;
  final String title;

  const VoiceTextContent({super.key, required this.text, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkPurple,
              fontFamily: AppAssets.fontFamily,
            ),
          ),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.darkPurple,
              fontFamily: AppAssets.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}