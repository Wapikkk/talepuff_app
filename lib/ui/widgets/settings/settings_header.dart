import 'package:flutter/material.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader ({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Row(
        children: [
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(Icons.arrow_back, color: AppColors.darkPurple, size: 28,),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 15),
          const Text(
            'Settings',
            style: TextStyle(
              fontFamily: AppAssets.fontFamily,
              color: AppColors.darkPurple,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}