import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_colors.dart';
import 'package:talepuff_app/core/app_assets.dart';

class VoiceImageHeader extends StatelessWidget{
  final String imageUrl;
  final VoidCallback onBackPressed;
  final VoidCallback onFavoritePressed;

  const VoiceImageHeader({
    super.key,
    required this.imageUrl,
    required this.onBackPressed,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.voiceImageHeader,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),

      child: SafeArea(
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: onBackPressed,
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.favorite_border,
                      color: Colors.white, 
                      size: 28,
                    ),
                    onPressed: onFavoritePressed,
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Text(
              "Image\nAI generate",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white54,
                fontSize: 24,
                fontFamily: AppAssets.fontFamily,
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}