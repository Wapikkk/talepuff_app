import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talepuff_app/ui/view_models/parents/child_info_view_model.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../shared/app_ui_helper.dart';

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
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppUIHelper.buildLabel(l10n.childName, isRequired: true),
        const SizedBox(height: 8),
        AppUIHelper.buildTextField(
          controller: nameController,
          hint: l10n.enterChildName,
          onChanged: (value) => viewModel.updateName(value),
        ),
        const SizedBox(height: 20),
        AppUIHelper.buildLabel(l10n.age, isRequired: false),
        const SizedBox(height: 8),
        AppUIHelper.buildTextField(
          controller: ageController,
          hint: l10n.enterAgeOptional,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2),
          ],
          onChanged: (value) => viewModel.age = value,
        ),
      ],
    );
  }
}