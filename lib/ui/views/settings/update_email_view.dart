import '../../widgets/shared/dismiss_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/account_result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_message_text.dart';
import '../../view_models/parents/update_settings_view_model.dart';
import '../../widgets/shared/top_banner.dart';
import '../../widgets/update_settings/inline_error.dart';
import '../../widgets/update_settings/update_btn_settings.dart';
import '../../widgets/update_settings/update_header_settings.dart';
import '../../widgets/update_settings/update_input_settings.dart';

class UpdateEmailView extends StatefulWidget {
  const UpdateEmailView({super.key});

  @override
  State<UpdateEmailView> createState() => _UpdateEmailViewState();
}

class _UpdateEmailViewState extends State<UpdateEmailView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<UpdateSettingsViewModel>().clearError();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final updateVM = context.read<UpdateSettingsViewModel>();
    final overlay = TopBanner.overlayOf(context);
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context);

    final result = await updateVM.requestEmailChange(
      newEmail: _emailController.text,
      currentPassword: _passwordController.text,
    );

    if (result is! AccountSuccess) return;
    TopBanner.show(
      overlay,
      l10n.appMessage(result.message, detail: result.value),
      duration: const Duration(seconds: 6),
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final updateVM = context.watch<UpdateSettingsViewModel>();
    final l10n = AppLocalizations.of(context);

    return DismissKeyboard(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UpdateHeaderSettings(title: l10n.email),
                const SizedBox(height: 20),
                UpdateInputSettings(
                  label: l10n.newEmail,
                  hint: 'user123@gmail.com',
                  controller: _emailController,
                ),
                const SizedBox(height: 20),
                UpdateInputSettings(
                  label: l10n.currentPassword,
                  hint: l10n.enterCurrentPassword,
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                UpdateBtnSettings(
                  text: l10n.updateEmail,
                  isBusy: updateVM.isLoading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 12),
                InlineError(message: updateVM.error),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
