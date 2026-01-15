import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_assets.dart';

class SignUpBtn extends StatelessWidget {
  const SignUpBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildBtn(
            "Sign Up",
            Colors.white,
            Colors.black,
        ),
        const SizedBox(height: 12),
        _buildBtn(
            "Sign Up with Google",
            const Color(0xFFFF8C39),
            Colors.white
        ),
      ],
    );
  }

  Widget _buildBtn(String text, Color bgColor, Color textColor) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
          ),
        ),
        child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              fontFamily: AppAssets.fontFamily,
            ),
        ),
      ),
    );
  }
}