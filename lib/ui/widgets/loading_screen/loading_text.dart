import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_assets.dart';

class LoadingText extends StatelessWidget{
  const LoadingText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 40,
          child: DefaultTextStyle(
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: AppAssets.fontFamily,
              color: Colors.white,
            ),
            child: AnimatedTextKit(
              repeatForever: true,
              isRepeatingAnimation: true,
              animatedTexts: [
                TypewriterAnimatedText(
                  'Story is generating...',
                  speed: const Duration(milliseconds: 120),
                  cursor: '',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}