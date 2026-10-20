import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/account_result.dart';
import '../../view_models/parents/child_info_view_model.dart';
import '../../view_models/parents/parent_view_model.dart';
import '../../view_models/parents/update_settings_view_model.dart';
import '../../widgets/shared/top_banner.dart';
import '../../widgets/update_settings/inline_error.dart';
import '../../widgets/update_settings/update_btn_settings.dart';
import '../../widgets/update_settings/update_header_settings.dart';
import '../../widgets/update_settings/update_input_settings.dart';

class UpdateChildNameView extends StatefulWidget {
  const UpdateChildNameView({super.key});

  @override
  State<UpdateChildNameView> createState() => _UpdateChildNameViewState();
}

class _UpdateChildNameViewState extends State<UpdateChildNameView> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<UpdateSettingsViewModel>().clearError();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final updateVM = context.read<UpdateSettingsViewModel>();
    final parentVM = context.read<ParentViewModel>();
    final childInfoVM = context.read<ChildInfoViewModel>();
    final overlay = TopBanner.overlayOf(context);
    final navigator = Navigator.of(context);

    final result = await updateVM.updateChildName(
      childId: parentVM.currentChildId,
      name: _nameController.text,
    );

    if (result is! AccountSuccess) return;
    final newName = result.value ?? _nameController.text.trim();
    parentVM.updateLocalChildName(newName);
    childInfoVM.applySavedName(newName);
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
              const UpdateHeaderSettings(title: "Child's Name"),
              const SizedBox(height: 20),
              UpdateInputSettings(
                label: "Child's Name",
                hint: "Enter your child's name",
                controller: _nameController,
              ),
              const SizedBox(height: 40),
              UpdateBtnSettings(
                text: 'Update Name',
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
