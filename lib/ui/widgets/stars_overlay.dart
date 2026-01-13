import 'package:flutter/material.dart';

class StarsOverlay extends StatelessWidget {
  const StarsOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isTablet = screenWidth > 600;

    return SizedBox(
      width: screenWidth,
      height: MediaQuery.of(context).size.height * 0.4,
      child: Stack(
        children: [
          _buildStarIcon(top: 40, left: screenWidth * 0.15, size: 12, opacity: 0.5),
          _buildStarIcon(top: 60, left: screenWidth * 0.45, size: 8, opacity: 0.4),
          _buildStarIcon(top: 30, right: screenWidth * 0.2, size: 14, opacity: 0.35),
          _buildStarIcon(top: 120, left: screenWidth * 0.25, size: 10, opacity: 0.5),
          _buildStarIcon(top: 170, right: screenWidth * 0.2, size: 6, opacity: 0.3),
          _buildStarIcon(top: 200, left: screenWidth * 0.6, size: 12, opacity: 0.45),
          _buildStarIcon(top: 90, right: screenWidth * 0.05, size: 9, opacity: 0.5),
          _buildStarIcon(top: 240, left: screenWidth * 0.1, size: 11, opacity: 0.4),

          if (isTablet) ...[
            _buildStarIcon(
              top: 260,
              right: screenWidth * 0.25,
              size: 8,
              opacity: 0.45,
            ),
            _buildStarIcon(
              top: 150,
              left: screenWidth * 0.4,
              size: 6,
              opacity: 0.35,
            ),
            _buildStarIcon(
              top: 250,
              left: screenWidth * 0.45,
              size: 10,
              opacity: 0.4,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStarIcon({
    required double top,
    double? left,
    double? right,
    required double size,
    required double opacity,
    IconData icon = Icons.star,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      child: Opacity(
        opacity: opacity,
        child: Icon(
          icon,
          size: size,
          color: Colors.white,
        ),
      ),
    );
  }
}