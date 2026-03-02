import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/update_settings/update_header_settings.dart';
import '../../widgets/update_settings/update_input_settings.dart';
import '../../widgets/update_settings/update_btn_settings.dart';
import '../../../ui/view_models/update_settings_view_model.dart';
import '../../../ui/view_models/parent_view_model.dart';

class UpdateChildNameView extends StatefulWidget {
  const UpdateChildNameView({super.key});

  @override
  State<UpdateChildNameView> createState() => _UpdateChildNameViewState();
}

class _UpdateChildNameViewState extends State<UpdateChildNameView> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final updateVM = context.watch<UpdateSettingsViewModel>();
    final parentVM = context.watch<ParentViewModel>();

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
                controller: _nameController ,
              ),

              const SizedBox(height: 40),

              UpdateBtnSettings(
                text: "Update Name",
                onPressed: () {
                  if (_nameController.text.isNotEmpty && parentVM.currentChildId != null) {
                    updateVM.updateChildName(
                      context,
                      parentVM.currentChildId!,
                      _nameController.text.trim(),
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