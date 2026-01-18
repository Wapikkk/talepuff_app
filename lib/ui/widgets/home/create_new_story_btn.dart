import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_assets.dart';
import 'package:talepuff_app/core/app_colors.dart';

class CreateNewStoryBtn extends StatelessWidget{
  final VoidCallback onPressed;

  const CreateNewStoryBtn ({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.6,
      height: 50,

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPurple.withOpacity(0.2),
            spreadRadius: -4,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Image.asset(
            AppAssets.iconWandStarsHome,
            color: Colors.white,
            width: 15,
            height: 15,
          ),
          label: const Text(
            'Create New Story',
            style: TextStyle(
              color: Colors.white,
              fontFamily: AppAssets.fontFamily,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.darkPurple,
            minimumSize: Size(screenWidth * 0.6, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
    );
  }
}