import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_assets.dart';
import 'package:talepuff_app/core/app_colors.dart';

class Mascot extends StatelessWidget{
  final String mascotId;

  const Mascot({
    super.key,
    required this.mascotId,
  });

  @override
  Widget build(BuildContext context) {
    String assetPath;
    // 1. Logika pemilihan asset tetap sama seperti permintaanmu
    switch (mascotId) {
      case 'OrangUtan':
        assetPath = AppAssets.mascotOrangUtan;
        break;
      case 'Badak':
        assetPath = AppAssets.mascotBadak;
        break;
      case 'Burung':
        assetPath = AppAssets.mascotBurung;
        break;
      case 'Harimau':
      default:
        assetPath = AppAssets.mascotHarimauSumatera;
    }

    final double mascotWidth = MediaQuery.of(context).size.width * 0.75;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            height: 25,
            width: mascotWidth * 0.6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.elliptical(mascotWidth, 30),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowMascot.withValues(alpha: 0.4),
                  blurRadius: 20, 
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
        ),

        Image.asset(
          assetPath,
          width: mascotWidth,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}