// lib/ui/widgets/signup/signup_input_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/core/app_colors.dart';
import '../../view_models/signup_view_model.dart';
import '../child_info/child_info_ui_helper.dart';
import '../../../core/app_assets.dart';

class SignUpInputForm extends StatefulWidget {
  const SignUpInputForm({super.key});

  @override
  State<SignUpInputForm> createState() => _SignUpInputFormState();
}

class _SignUpInputFormState extends State<SignUpInputForm> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<SignUpViewModel>();
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
    final viewModel = context.watch<SignUpViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChildInfoUIHelper.buildLabel("Email", isRequired: true),
        const SizedBox(height: 8),
        ChildInfoUIHelper.buildTextField(
          controller: emailController,
          hint: "Enter your email",
          onChanged: (v) => viewModel.updateEmail(v),
        ),

        const SizedBox(height: 20),

        ChildInfoUIHelper.buildLabel("Password", isRequired: true),
        const SizedBox(height: 8),
        ChildInfoUIHelper.buildTextField(
          controller: passwordController,
          hint: "Enter your password",
          onChanged: (v) => viewModel.updatePassword(v),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Checkbox(
              value: viewModel.isAccepted,
              onChanged: (val) => viewModel.toggleAccepted(val!),
              side: const BorderSide(
                  color: Colors.white,
              ),
              activeColor: AppColors.underline,
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                    fontFamily: AppAssets.fontFamily,
                  ),
                  children: [
                    TextSpan(text: "I accept the "),
                    TextSpan(
                      text: "terms of service",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(text: " & "),
                    TextSpan(
                      text: "privacy policy",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}