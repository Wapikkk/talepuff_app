import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_assets.dart';
import 'package:talepuff_app/core/app_colors.dart';

class ChoiceChipGroup extends StatefulWidget {
  final List<String> options;

  const ChoiceChipGroup({super.key, required this.options});

  @override
  State<ChoiceChipGroup> createState() => _ChoiceChipGroupState();
}

class _ChoiceChipGroupState extends State<ChoiceChipGroup> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: widget.options.map((option) {
        final isSelected = selectedOption == option;
        return GestureDetector(
          onTap: () {
            setState(() {
              if (selectedOption == option) {
                selectedOption = null;
              } else {
                selectedOption = option;
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 50),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? null : Colors.white,
              gradient: isSelected
                  ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.topRight,
                colors: [
                  AppColors.primaryPurple, // Stop 0%
                  AppColors.listCreate2, // Stop 100%
                ],
              )
                  : null,

              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  spreadRadius: 1,
                  blurRadius: 8,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.darkPurple,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                fontFamily: AppAssets.fontFamily,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}