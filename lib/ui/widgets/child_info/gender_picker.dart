import 'package:talepuff_app/ui/view_models/child_info_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'child_info_ui_helper.dart';

class GenderPicker extends StatelessWidget{
  const GenderPicker ({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChildInfoViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChildInfoUIHelper.buildLabel("Gender", isRequired: true),
        const SizedBox(height: 12),
        Row(
          children: ['male', 'female', 'n/a'].map((g) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ChildInfoUIHelper.buildSelectableBox(
                    label: g,
                    isSelected: viewModel.selectedGender == g,
                    onTap: () => viewModel.updateGender(g)
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}