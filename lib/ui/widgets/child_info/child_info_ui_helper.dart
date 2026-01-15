import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_colors.dart';
import '../../../core/app_assets.dart';

class ChildInfoUIHelper {
  static Widget buildLabel(String text, {bool isRequired = false}) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: AppAssets.fontFamily
        ),
        children: isRequired
            ? [const TextSpan(text: " *", style: TextStyle(color: Colors.red))]
            : [],
      ),
    );
  }

  static Widget buildSelectableBox({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    double? width,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.underline.withValues(alpha: 0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.5)
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontFamily: AppAssets.fontFamily,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  static Widget buildTextField({
    required String hint,
    required Function(String) onChanged,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      autofocus: false,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: Colors.white,
            fontSize: 14
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  static Widget buildInterestChip({
    required String iconPath,
    required String label,
    required bool isSelected,
    required VoidCallback onTap
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.underline.withValues(alpha: 0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
              color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.3)
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              iconPath,
              width: 20,
              height: 20,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontFamily: AppAssets.fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }
}