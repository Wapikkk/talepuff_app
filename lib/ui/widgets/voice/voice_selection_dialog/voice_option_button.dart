import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_assets.dart';
import '../../../view_models/voice/voice_selection_dialog/voice_selection_dialog_view_model.dart';
import 'package:talepuff_app/core/app_colors.dart';

class VoiceOptionButton extends StatelessWidget{
  final VoiceOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const VoiceOptionButton({
    super.key,
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 130,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gradient4 : Colors.white,
          border: Border.all(color: AppColors.gradient4, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              isSelected ? option.selectedIconPath : option.unselectedIconPath,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? AppColors.darkPurple : AppColors.gradient4,
                fontFamily: AppAssets.fontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              child: Text(option.title),
            ),
          ],
        ),
      ),
    );
  }
}