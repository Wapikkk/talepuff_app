import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/auth/login_view_model.dart';
import '../../../l10n/app_localizations.dart';
import '../shared/app_ui_helper.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';

class LoginInputForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginInputForm({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppUIHelper.buildLabel(l10n.email, isRequired: true),
        const SizedBox(height: 8),
        AppUIHelper.buildTextField(
          controller: emailController,
          hint: l10n.enterEmail,
          onChanged: (v) => viewModel.updateEmail(v),
        ),
        const SizedBox(height: 20),

        AppUIHelper.buildLabel(l10n.password, isRequired: true),
        const SizedBox(height: 8),
        AppUIHelper.buildTextField(
          controller: passwordController,
          hint: l10n.enterPassword,
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
                  onChanged: (val) => viewModel.toggleRememberMe(val ?? false),
                  side: const BorderSide(
                    color: Colors.white,
                  ),
                  activeColor: AppColors.underline,
                ),
                Text(
                  l10n.rememberMe,
                  style: const TextStyle(
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
                l10n.forgotPassword,
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