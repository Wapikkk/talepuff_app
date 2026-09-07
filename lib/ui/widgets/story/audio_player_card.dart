import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_colors.dart';
import 'package:talepuff_app/core/app_assets.dart';

class AudioPlayerCard extends StatelessWidget{
  const AudioPlayerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Icon(
                Icons.graphic_eq,
                size: 50,
                color: AppColors.darkPurple,
              ),
            ),
          ),

          const SizedBox(height: 16),

          const Text(
            "Aira's Space Adventure",
            style: TextStyle(
              fontFamily: AppAssets.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.linearButton,
            ),
          ),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              trackHeight: 4,
              activeTrackColor: AppColors.darkPurple,
              inactiveTrackColor: Colors.white,
              thumbColor: AppColors.darkPurple,
            ),
            child: Slider(
              value: 0.4,
              onChanged: (value) {},
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "1:40",
                  style: TextStyle(
                    fontFamily: AppAssets.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.linearButton,
                  ),
                ),
                Text(
                  "3:00",
                  style: TextStyle(
                    fontFamily: AppAssets.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.linearButton,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.replay_10,
                  size: 28,
                  color: AppColors.linearButton,
                ),
                onPressed: () {},
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.linearButton,
                    width: 3,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.pause,
                    size: 36,
                    color: AppColors.linearButton,
                  ),
                  onPressed: () {},
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.favorite_border,
                  size: 28,
                  color: AppColors.linearButton,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}