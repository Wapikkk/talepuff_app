import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_colors.dart';
import '../../../data/models/auth_result.dart';
import '../../auth_flow.dart';
import '../../view_models/auth/login_view_model.dart';
import '../shared/auth_button.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoginViewModel>();

    return Column(
      children: [
        AuthButton(
          label: 'Login',
          background: AppColors.btnSave,
          isBusy: viewModel.isLoading,
          showSpinner: viewModel.activeMethod == AuthMethod.email,
          onPressed: () => _submit(context, viewModel.login),
        ),
        const SizedBox(height: 12),
        AuthButton(
          label: 'Continue with Google',
          background: const Color(0xFFFF8C39),
          isBusy: viewModel.isLoading,
          showSpinner: viewModel.activeMethod == AuthMethod.google,
          onPressed: () => _submit(context, viewModel.loginWithGoogle),
        ),
      ],
    );
  }

  Future<void> _submit(BuildContext context, Future<AuthResult> Function() action) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final result = await action();
    if (!context.mounted) {
      debugPrint('[auth] result ${result.runtimeType} dropped: the screen was already closed');
      return;
    }
    AuthFlow.proceed(context, result);
  }
}
