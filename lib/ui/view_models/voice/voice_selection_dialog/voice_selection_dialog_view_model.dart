import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_assets.dart';

class VoiceOption {
  final String title;
  final String unselectedIconPath;
  final String selectedIconPath;

  VoiceOption ({required this.title, required this.unselectedIconPath, required this.selectedIconPath});
}

class VoiceSelectionDialogViewModel extends ChangeNotifier{
  final List<VoiceOption> voiceOptions = [
    VoiceOption(
      title: "Warm",
      unselectedIconPath: AppAssets.iconFavoriteOrange,
      selectedIconPath: AppAssets.iconFavoriteDarkPurple,
    ),
    VoiceOption(
      title: "Brave",
      unselectedIconPath: AppAssets.iconSecurityOrange,
      selectedIconPath: AppAssets.iconSecurityDarkPurple,
    ),
    VoiceOption(
      title: "Gentle",
      unselectedIconPath: AppAssets.iconModeNightOrange,
      selectedIconPath: AppAssets.iconModeNightDarkPurple,
    ),
    VoiceOption(
      title: "Character",
      unselectedIconPath: AppAssets.iconPetsOrange,
      selectedIconPath: AppAssets.iconPetsDarkPurple,
    ),
    VoiceOption(
      title: "Friendly",
      unselectedIconPath: AppAssets.iconSentimentExcitedOrange,
      selectedIconPath: AppAssets.iconSentimentExcitedDarkPurple,
    ),
    VoiceOption(
      title: "Neutral",
      unselectedIconPath: AppAssets.iconBrandAwarenessOrange,
      selectedIconPath: AppAssets.iconBrandAwarenessDarkPurple,
    ),
  ];

  int _selectedIndex = -1;
  int get selectedIndex => _selectedIndex;

  void selectVoice(int index){
    _selectedIndex = index;
    notifyListeners();
  }

  bool isSelected(int index) => _selectedIndex == index;

  VoiceOption? getSelectedVoice() {
    if (_selectedIndex == -1) return null;
    return voiceOptions[_selectedIndex];
  }
}