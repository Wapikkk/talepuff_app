import 'package:flutter/material.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';

class StoryThemeStyle {
  final Color color;
  final Color iconColor;
  final String? iconAsset;
  const StoryThemeStyle(this.color, this.iconColor, this.iconAsset);

  static StoryThemeStyle of(String theme) {
    switch (theme) {
      case 'Daily':
        return const StoryThemeStyle(AppColors.logout, Colors.white, AppAssets.iconClearDay);
      case 'Friendship':
        return const StoryThemeStyle(AppColors.friendshipBox, Colors.white, AppAssets.iconPets);
      case 'Adventure':
        return const StoryThemeStyle(AppColors.inputField, Colors.white, AppAssets.iconRocketLaunch);
      case 'Feeling':
        return const StoryThemeStyle(AppColors.feelingBox, AppColors.darkPurple, AppAssets.iconExcited);
      default:
        return const StoryThemeStyle(Color(0xFFA594F9), Colors.white, null);
    }
  }
}
