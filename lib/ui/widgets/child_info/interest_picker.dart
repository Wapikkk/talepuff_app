import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/ui/view_models/child_info_view_model.dart';
import 'child_info_ui_helper.dart';

class InterestPicker extends StatelessWidget{
  const InterestPicker ({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ChildInfoViewModel>();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ChildInfoUIHelper.buildLabel("Interest", isRequired: true),
            Text(
              "${3 - viewModel.selectedInterests.length} slots remaining",
              style: const TextStyle(
                  color: Color(0xFF00CBA7),
                  fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: viewModel.allInterestData.map((interest) {
            final interestName = interest['name']!;
            final iconPath = interest['icon']!;

            return ChildInfoUIHelper.buildInterestChip(
              label: interestName,
              iconPath: iconPath,
              isSelected: viewModel.selectedInterests.contains(interestName),
              onTap: () => viewModel.toggleInterest(interestName),
            );
          }).toList(),
        ),
      ],
    );
  }
}