import 'package:talepuff_app/ui/view_models/parents/child_info_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/l10n_labels.dart';
import '../shared/app_ui_helper.dart';

class GenderPicker extends StatelessWidget{
  const GenderPicker ({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChildInfoViewModel>();
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppUIHelper.buildLabel(l10n.gender, isRequired: true),
        const SizedBox(height: 12),
        Row(
          children: ['male', 'female', 'n/a'].map((g) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: AppUIHelper.buildSelectableBox(
                    label: l10n.genderLabel(g),
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