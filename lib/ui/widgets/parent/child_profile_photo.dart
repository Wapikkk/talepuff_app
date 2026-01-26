import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_colors.dart';
import '../../../core/app_assets.dart';

class ChildProfilePhoto extends StatelessWidget {
  const ChildProfilePhoto({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const CircleAvatar(
            radius: 64,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage(AppAssets.mascotHarimauSumatera),
            ),
          ),
        ),

        Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: AppColors.listCreate1,
              shape: BoxShape.circle,
            ),
            child: Image.asset(
              AppAssets.iconStylus,
              width: 20,
              height: 20,
            ),
          ),
        ),
      ],
    );
  }
}