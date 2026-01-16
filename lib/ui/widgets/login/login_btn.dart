import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/login_view_model.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: () {
          FocusManager.instance.primaryFocus?.unfocus();
          viewModel.login(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.btnSave,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: const Text(
          "Login",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
      ),
    );
  }
}