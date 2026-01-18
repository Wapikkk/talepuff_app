import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_assets.dart';
import 'package:talepuff_app/core/app_colors.dart';

class HomeSearchBar extends StatelessWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        height: 35,
        width: screenWidth * 0.78,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.55),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: TextField(
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: "Search your story",
            isDense: true,
            hintStyle: const TextStyle(
              color: AppColors.primaryPurple,
              fontFamily: AppAssets.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            suffixIcon: const Icon(
              Icons.search,
              color: AppColors.darkPurple,
              size: 22,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          style: const TextStyle(
            color: AppColors.darkPurple,
            fontFamily: AppAssets.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}