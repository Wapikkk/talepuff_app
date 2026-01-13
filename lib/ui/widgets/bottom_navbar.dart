import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_colors.dart';
import 'package:talepuff_app/core/app_assets.dart';

class BottomNavbar extends StatelessWidget{
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    const selectedColor = AppColors.darkPurple;
    const unselectedColor = AppColors.primaryPurple;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),

        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: selectedColor,
          unselectedItemColor: unselectedColor,
          mouseCursor: SystemMouseCursors.click,
          selectedFontSize: 12,
          unselectedFontSize: 12,

          selectedLabelStyle: const TextStyle(
            fontFamily: AppAssets.fontFamily,
            fontWeight: FontWeight.bold,
          ),

          unselectedLabelStyle: const TextStyle(
            fontFamily: AppAssets.fontFamily,
            fontWeight: FontWeight.bold,
          ),

          items: [
            BottomNavigationBarItem(
                icon: _buildIcon(AppAssets.iconHome, 0, selectedColor, unselectedColor),
                label: 'Home',
            ),
            BottomNavigationBarItem(
                icon: _buildIcon(AppAssets.iconStory, 1, selectedColor, unselectedColor),
                label: 'Story',
            ),
            BottomNavigationBarItem(
                icon: _buildIcon(AppAssets.iconCreate, 2, selectedColor, unselectedColor),
                label: 'Create',
            ),
            BottomNavigationBarItem(
                icon: _buildIcon(AppAssets.iconParents, 3, selectedColor, unselectedColor),
                label: 'Parents',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(String assetPath, int index, Color selectedColor, Color unselectedColor) {
    bool isSelected = currentIndex == index;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 4),
          width: isSelected ? 30 : 0,
          height: 3,
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Image.asset(
          assetPath,
          width: 20,
          height: 20,
          color: currentIndex == index ? selectedColor : unselectedColor,
          colorBlendMode: BlendMode.srcIn,
        ),
      ],
    );
  }
}