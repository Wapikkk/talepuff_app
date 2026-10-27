import '../../widgets/shared/dismiss_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/account_result.dart';
import '../../../core/validators.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_message_text.dart';
import '../../view_models/parents/update_settings_view_model.dart';
import '../../widgets/shared/top_banner.dart';
import '../../widgets/update_settings/inline_error.dart';
import '../../widgets/update_settings/update_btn_settings.dart';
import '../../widgets/update_settings/update_header_settings.dart';
import '../../widgets/update_settings/update_input_settings.dart';

class UpdatePasswordView extends StatefulWidget {
  const UpdatePasswordView({super.key});

  @override
  State<UpdatePasswordView> createState() => _UpdatePasswordViewState();
}

class _UpdatePasswordViewState extends State<UpdatePasswordView> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<UpdateSettingsViewModel>().clearError();
    });
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final updateVM = context.read<UpdateSettingsViewModel>();
    final overlay = TopBanner.overlayOf(context);
    final navigator = Navigator.of(context);
    final l10n = AppLocalizations.of(context);

    final result = await updateVM.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (result is! AccountSuccess) return;
    TopBanner.show(overlay, l10n.appMessage(result.message, detail: result.value));
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
                UpdateHeaderSettings(title: l10n.updatePassword),
                const SizedBox(height: 20),
                UpdateInputSettings(
                  label: l10n.currentPassword,
                  hint: l10n.enterCurrentPassword,
                  controller: _currentPasswordController,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                UpdateInputSettings(
                  label: l10n.newPassword,
                  hint: l10n.newPasswordHint(AuthValidators.minPasswordLength),
                  controller: _newPasswordController,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                UpdateInputSettings(
                  label: l10n.confirmPassword,
                  hint: l10n.confirmNewPassword,
                  controller: _confirmPasswordController,
                  obscureText: true,
                ),
                const SizedBox(height: 40),
                UpdateBtnSettings(
                  text: l10n.updatePassword,
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
