import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';
import '../../../../core/app_assets.dart';

class GetStartedBtn extends StatelessWidget{
  final VoidCallback onPressed;
  const GetStartedBtn ({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.65,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkPurple.withOpacity(0.9),
            blurRadius: 10,
            spreadRadius: -4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPurple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Let’s go',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: AppAssets.fontFamily,
            shadows: [
              Shadow(
                blurRadius: 11.0,
                color: Colors.white,
                offset: Offset(0, 0),
              ),
            ],// Quicksand
          ),
        ),
      ),
    );
  }
}