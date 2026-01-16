import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/signup_view_model.dart';
import 'package:talepuff_app/core/app_assets.dart';

class SignUpBtn extends StatelessWidget {
  const SignUpBtn({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignUpViewModel>();

    return Column(
      children: [
        _buildBtn(
            "Sign Up",
            Colors.white,
            Colors.black,
            (){
              FocusManager.instance.primaryFocus?.unfocus();
              viewModel.signUpManual(context);
            },
        ),

        const SizedBox(height: 12),
        _buildBtn(
            "Sign Up with Google",
            const Color(0xFFFF8C39),
            Colors.white,
              () {
            FocusManager.instance.primaryFocus?.unfocus();
            viewModel.signUpWithGoogle(context);
          },
        ),
      ],
    );
  }

  Widget _buildBtn(String text, Color bgColor, Color textColor, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
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