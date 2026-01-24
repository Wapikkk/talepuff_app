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
        'icon': AppAssets.iconSun, // ini nanti diganti dengan icon matahari
      };
    } else if (hour >= 12 && hour < 17) {
      return {
        'text': 'Good Afternoon',
        'icon': AppAssets.iconCloudSun, // ini nanti diganti dengan icon matahari
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
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
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            _buildWeatherIcon(theme['icon']),
          ],
        ),
        const SizedBox(height: 8),
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

Widget _buildWeatherIcon(String iconPath) {
  return Stack(
    alignment: Alignment.center,
    children: [
      ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Image.asset(
          iconPath,
          color: Colors.white54,
          width: 26,
          height: 26,
        ),
      ),
      Image.asset(
        iconPath,
        color: Colors.white,
        width: 22,
        height: 22,
      ),
    ],
  );
}