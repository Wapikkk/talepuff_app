import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_colors.dart';
import '../../../core/app_assets.dart';

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.darkPurple,
          fontFamily: AppAssets.fontFamily,
        ),
      ),
    );
  }
}