import 'package:flutter/material.dart';
import '../../../core/app_colors.dart';

class DividerLine extends StatelessWidget {
  final double height;
  final double verticalPadding;

  const DividerLine({
    super.key,
    this.height = 3.0,
    this.verticalPadding = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.dividerLine,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ),
    );
  }
}