import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/core/app_colors.dart';
import '../../view_models/auth/signup_view_model.dart';
import '../shared/app_ui_helper.dart';
import '../../../core/app_assets.dart';
import '../../../data/models/legal_document.dart';
import '../../../l10n/app_localizations.dart';

class SignUpInputForm extends StatefulWidget {
  const SignUpInputForm({super.key});

  @override
  State<SignUpInputForm> createState() => _SignUpInputFormState();
}

class _SignUpInputFormState extends State<SignUpInputForm> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late final TapGestureRecognizer _termsTap = TapGestureRecognizer()
    ..onTap = () => Navigator.pushNamed(context, '/legal', arguments: LegalDocument.terms);
  late final TapGestureRecognizer _privacyTap = TapGestureRecognizer()
    ..onTap = () => Navigator.pushNamed(context, '/legal', arguments: LegalDocument.privacy);

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
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignUpViewModel>();
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppUIHelper.buildLabel(l10n.email, isRequired: true),
        const SizedBox(height: 8),
        AppUIHelper.buildTextField(
          hint: l10n.enterEmail,
          onChanged: (v) => viewModel.updateEmail(v),
        ),

        const SizedBox(height: 20),

        AppUIHelper.buildLabel(l10n.password, isRequired: true),
        const SizedBox(height: 8),
        AppUIHelper.buildTextField(
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
                    TextSpan(text: l10n.acceptTermsPrefix),
                    TextSpan(
                      text: l10n.termsOfService,
                      recognizer: _termsTap,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(text: l10n.acceptTermsAnd),
                    TextSpan(
                      text: l10n.privacyPolicyLink,
                      recognizer: _privacyTap,
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