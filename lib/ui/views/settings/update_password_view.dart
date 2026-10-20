import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/account_result.dart';
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

    final result = await updateVM.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      confirmPassword: _confirmPasswordController.text,
    );

    if (result is! AccountSuccess) return;
    TopBanner.show(overlay, result.message);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final updateVM = context.watch<UpdateSettingsViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const UpdateHeaderSettings(title: 'Update Password'),
              const SizedBox(height: 20),
              UpdateInputSettings(
                label: 'Current password',
                hint: 'Enter current password',
                controller: _currentPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              UpdateInputSettings(
                label: 'New password',
                hint: 'At least 8 characters, letters and numbers',
                controller: _newPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 20),
              UpdateInputSettings(
                label: 'Confirm password',
                hint: 'Confirm your new password',
                controller: _confirmPasswordController,
                obscureText: true,
              ),
              const SizedBox(height: 40),
              UpdateBtnSettings(
                text: 'Update Password',
                isBusy: updateVM.isLoading,
                onPressed: _submit,
              ),
              const SizedBox(height: 12),
              InlineError(message: updateVM.errorMessage),
            ],
          ),
        ),
      ),
    );
  }
}
