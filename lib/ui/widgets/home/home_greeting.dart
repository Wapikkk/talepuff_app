import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:talepuff_app/core/app_assets.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/ui/view_models/child_info_view_model.dart';

class HomeGreeting extends StatelessWidget{
  const HomeGreeting({super.key});

  Map<String, dynamic> _getTimeTheme() {
    final hour = DateTime.now().hour;

    if (hour >= 5 && hour < 12) {
      return {
        'text': 'Good Morning',
        'icon': AppAssets.iconMoonStars, // ini nanti diganti dengan icon matahari
      };
    } else if (hour >= 12 && hour < 17) {
      return {
        'text': 'Good Afternoon',
        'icon': AppAssets.iconMoonStars, // ini nanti diganti dengan icon matahari
      };
    } else {
      return {
        'text': 'Good Evening',
        'icon': AppAssets.iconMoonStars,
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final childName = context.watch<ChildInfoViewModel>().childName;
    final theme = _getTimeTheme();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
            "${theme['text']}, $childName",
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
            const SizedBox(height: 8),

            Stack(
              alignment: Alignment.center,
              children: [
                ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                  child: Image.asset(
                    theme['icon'],
                    color: Colors.white54,
                    width: 26,
                    height: 26,
                  ),
                ),
                Image.asset(
                  theme['icon'],
                  color: Colors.white,
                  width: 22,
                  height: 22,
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
        ),
      ],
    );
  }
}