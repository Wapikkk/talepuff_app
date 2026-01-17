import 'package:flutter/material.dart';
import '../../../core/app_assets.dart';

class LandingHeader extends StatelessWidget {
  const LandingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Create your own story",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Help your child learn English through stories they love",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: AppAssets.fontFamily,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}