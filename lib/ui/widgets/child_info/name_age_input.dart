import 'package:flutter/material.dart';
import 'package:talepuff_app/ui/view_models/child_info_view_model.dart';
import 'package:provider/provider.dart';
import 'child_info_ui_helper.dart';

class NameAgeInput extends StatefulWidget {
  const NameAgeInput({super.key});

  @override
  State<NameAgeInput> createState() => _NameAgeInputState();
}

class _NameAgeInputState extends State<NameAgeInput> {
  late TextEditingController nameController;
  late TextEditingController ageController;

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<ChildInfoViewModel>();
    nameController = TextEditingController(text: viewModel.name);
    ageController = TextEditingController(text: viewModel.age);
  }

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChildInfoViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChildInfoUIHelper.buildLabel("Child’s Name", isRequired: true),
        const SizedBox(height: 8),
        ChildInfoUIHelper.buildTextField(
          controller: nameController,
          hint: "Enter the name of your child",
          onChanged: (value) => viewModel.updateName(value),
        ),
        const SizedBox(height: 20),
        ChildInfoUIHelper.buildLabel("Age", isRequired: false),
        const SizedBox(height: 8),
        ChildInfoUIHelper.buildTextField(
          controller: ageController,
          hint: "Enter age (optional)",
          onChanged: (value) => viewModel.age = value,
        ),
      ],
    );
  }
}