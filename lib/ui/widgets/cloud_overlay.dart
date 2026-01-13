import 'package:flutter/material.dart';
import '../../core/app_assets.dart';

class CloudOverlay extends StatelessWidget {
  const CloudOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth > 600;
    return Stack(
      children: [
        Positioned(
          top: 40,
          right: -30,
          child: _buildCloudStyle(
              AppAssets.cloud4,
              width: 100,
              opacity: 0.6,
          ),
        ),

        Positioned(
          top: 90,
          left: -20,
          child: _buildCloudStyle(
              AppAssets.cloud2,
              width: 120,
              opacity: 0.5,
          ),
        ),

        Positioned(
          top: 160,
          left: 40,
          child: _buildCloudStyle(
              AppAssets.cloud3,
              width: 100,
              opacity: 0.4
          ),
        ),

        Positioned(
          top: 220,
          right: -20,
          child: _buildCloudStyle(
              AppAssets.cloud1,
              width: 100,
              opacity: 0.3
          ),
        ),

        Positioned(
          top: 280,
          left: -10,
          child: _buildCloudStyle(
              AppAssets.cloud5,
              width: 80,
              opacity: 0.35
          ),
        ),

        Positioned(
          top: 130,
          right: 120,
          child: _buildCloudStyle(
              AppAssets.cloud6,
              width:70,
              opacity: 0.45
          ),
        ),

        if (isTablet) ...[
          Positioned(
            top: 80,
            left: screenWidth * 0.4,
            child: _buildCloudStyle(
                AppAssets.cloud2,
                width: 100,
                opacity: 0.45
            ),
          ),
          Positioned(
            top: 180,
            right: screenWidth * 0.55,
            child: _buildCloudStyle(
                AppAssets.cloud5,
                width: 70,
                opacity: 0.35
            ),
          ),
          Positioned(
            top: 250,
            left: screenWidth * 0.55,
            child: _buildCloudStyle(
                AppAssets.cloud2,
                width: 70,
                opacity: 0.35
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCloudStyle(String asset, {required double width, required double opacity}) {
    return Opacity(
      opacity: opacity,
      child: Image.asset(
        asset,
        width: width,
        fit: BoxFit.contain,
      ),
    );
  }
}