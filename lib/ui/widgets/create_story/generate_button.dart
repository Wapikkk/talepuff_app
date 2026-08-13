import 'package:flutter/material.dart';
import '../../../core/app_assets.dart';

class GenerateButton extends StatelessWidget {
  final VoidCallback onPressed;
  const GenerateButton ({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 40, bottom: 30),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.auto_awesome, color: Colors.white),
        label: const Text(
          "Generate Story",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF26183A),
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
      ),
    );
  }
}