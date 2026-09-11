import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ui/view_models/loading/loading_view_model.dart';
import 'package:talepuff_app/core/app_colors.dart';
import 'package:talepuff_app/core/app_assets.dart';

class LoadingProgress extends StatelessWidget{
  const LoadingProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoadingViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: viewModel.progress,
                  minHeight: 18,
                  backgroundColor: AppColors.darkPurple,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.gradient5),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "${(viewModel.progress * 100).toInt()}%",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkPurple,
                  fontFamily: AppAssets.fontFamily,
                ),
              ),
              Text(
                viewModel.timeRemaining,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkPurple,
                  fontFamily: AppAssets.fontFamily
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}