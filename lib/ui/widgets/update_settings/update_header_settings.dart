import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_assets.dart';

class UpdateHeaderSettings extends StatelessWidget {
  final String title;

  const UpdateHeaderSettings({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.darkPurple),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkPurple,
              fontFamily: AppAssets.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}