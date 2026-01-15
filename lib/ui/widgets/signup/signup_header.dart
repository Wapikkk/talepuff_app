import 'package:flutter/material.dart';
import '../../../core/app_assets.dart';

class SignUpHeader extends StatelessWidget{
  const SignUpHeader ({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: const Icon(
              Icons.arrow_back,
              color: Colors.white
          ),
          onPressed: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.pop(context);
          }
        ),
        const SizedBox(width: 16),
        const Text(
          "Sign Up",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
      ],
    );
  }
}