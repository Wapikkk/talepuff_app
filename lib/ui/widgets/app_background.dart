import 'package:flutter/material.dart';
import '../../core/app_colors.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground ({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.gradient1,
            AppColors.gradient2,
            AppColors.gradient3,
            AppColors.gradient4,
            AppColors.gradient5,
          ],
          stops: [0.0, 0.22, 0.5, 0.65, 0.79],
        ),
      ),
      child: child,
    );
  }
}