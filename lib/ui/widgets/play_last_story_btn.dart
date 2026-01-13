import 'package:flutter/material.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';

class PlayLastStoryBtn extends StatelessWidget{
  final VoidCallback onPressed;

  const PlayLastStoryBtn ({super.key, required this.onPressed});

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
            color: Colors.black54.withOpacity(0.2),
            spreadRadius: -4,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Image.asset(
          AppAssets.iconPlayArrow,
          color: AppColors.darkPurple,
          width: 14,
          height: 14,
        ),
        label: const Text(
          'Play Last Story',
          style: TextStyle(
            color: AppColors.darkPurple,
            fontFamily: AppAssets.fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          minimumSize: Size(screenWidth * 0.6, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }
}