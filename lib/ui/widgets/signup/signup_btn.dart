import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/auth_result.dart';
import '../../auth_flow.dart';
import '../../view_models/auth/signup_view_model.dart';
import '../shared/auth_button.dart';

class SignUpBtn extends StatelessWidget {
  const SignUpBtn({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SignUpViewModel>();

    return Column(
      children: [
        AuthButton(
          label: 'Sign Up',
          background: Colors.white,
          foreground: Colors.black,
          isBusy: viewModel.isLoading,
          showSpinner: viewModel.activeMethod == AuthMethod.email,
          onPressed: () => _submit(context, viewModel.signUpManual),
        ),
        const SizedBox(height: 12),
        AuthButton(
          label: 'Sign Up with Google',
          background: const Color(0xFFFF8C39),
          isBusy: viewModel.isLoading,
          showSpinner: viewModel.activeMethod == AuthMethod.google,
          onPressed: () => _submit(context, viewModel.signUpWithGoogle),
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
