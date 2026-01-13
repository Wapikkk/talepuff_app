import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:talepuff_app/core/app_assets.dart';

class HomeGreeting extends StatelessWidget{
  final String userName;

  const HomeGreeting({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Good Evening, $userName",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: AppAssets.fontFamily,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.white54,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Stack(
              alignment: Alignment.center,
              children: [
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Image.asset(
                    AppAssets.iconMoonStars,
                    color: Colors.white54,
                    width: 26,
                    height: 26,
                  ),
                ),
                Image.asset(
                  AppAssets.iconMoonStars,
                  color: Colors.white,
                  width: 22,
                  height: 22,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          "What story do you want to hear today?",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: AppAssets.fontFamily,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}