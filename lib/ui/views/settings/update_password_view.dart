import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/update_settings/update_header_settings.dart';
import '../../widgets/update_settings/update_input_settings.dart';
import '../../widgets/update_settings/update_btn_settings.dart';
import '../../../ui/view_models/parent_view_model.dart';

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
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parentVM = context.watch<ParentViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const UpdateHeaderSettings(title: "Update Password"),
              const SizedBox(height: 20),

              UpdateInputSettings(
                label: "Current password",
                hint: "Enter current password",
                controller: _currentPasswordController,
                obscureText: true,
              ),

              const SizedBox(height: 20),

              UpdateInputSettings(
                label: "Password",
                hint: "Enter new password",
                controller: _newPasswordController,
                obscureText: true,
              ),

              const SizedBox(height: 20),

              UpdateInputSettings(
                label: "Confirm password",
                hint: "Confirm your password",
                controller: _confirmPasswordController,
                obscureText: true,
              ),

              const SizedBox(height: 40),

              UpdateBtnSettings(
                text: "Update Password",
                onPressed: () {
                  if (_newPasswordController.text != _confirmPasswordController.text) {
                    debugPrint("Password mismatch!");
                    return;
                  }

                  if (_currentPasswordController.text.isNotEmpty &&
                      _newPasswordController.text.isNotEmpty) {
                    parentVM.updateParentPassword(
                      _currentPasswordController.text,
                      _newPasswordController.text,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}