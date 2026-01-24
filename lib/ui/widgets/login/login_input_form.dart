import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/login_view_model.dart';
import '../shared/app_ui_helper.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';

class LoginInputForm extends StatefulWidget {
  const LoginInputForm({super.key});

  @override
  State<LoginInputForm> createState() => _LoginInputFormState();
}

class _LoginInputFormState extends State<LoginInputForm> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<LoginViewModel>();
    emailController = TextEditingController(text: viewModel.email);
    passwordController = TextEditingController(text: viewModel.password);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppUIHelper.buildLabel("Email", isRequired: true),
        const SizedBox(height: 8),
        AppUIHelper.buildTextField(
          controller: emailController,
          hint: "Enter your email",
          onChanged: (v) => viewModel.updateEmail(v),
        ),
        const SizedBox(height: 20),

        AppUIHelper.buildLabel("Password", isRequired: true),
        const SizedBox(height: 8),
        AppUIHelper.buildTextField(
          controller: passwordController,
          hint: "Enter your password",
          onChanged: (v) => viewModel.updatePassword(v),
          obscureText: viewModel.isPasswordObscured,
          suffixIcon: IconButton(
            icon: Icon(
              viewModel.isPasswordObscured
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            onPressed: () => viewModel.togglePasswordVisibility(),
          ),
        ),

        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Checkbox(
                  value: viewModel.rememberMe,
                  onChanged: (val) => viewModel.toggleRememberMe(val!),
                  side: const BorderSide(
                    color: Colors.white,
                  ),
                  activeColor: AppColors.underline,
                ),
                const Text(
                  "Remember Me",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: AppAssets.fontFamily,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "Forgot Password?",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                  fontFamily: AppAssets.fontFamily,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}