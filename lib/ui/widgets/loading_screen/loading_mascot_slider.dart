import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/core/app_assets.dart';
import 'package:talepuff_app/core/app_colors.dart';
import '../../view_models/loading/loading_view_model.dart';

class LoadingMascotSlider extends StatefulWidget {
  const LoadingMascotSlider({super.key});

  @override
  State<LoadingMascotSlider> createState() => _LoadingMascotSliderState();
}

class _LoadingMascotSliderState extends State<LoadingMascotSlider> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoadingViewModel>().startAutoplay(_pageController, 4);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LoadingViewModel>();
    final List<String> mascots = [
      AppAssets.mascotBadak,
      AppAssets.mascotHarimauSumatera,
      AppAssets.mascotBurung,
      AppAssets.mascotOrangUtan,
    ];

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: mascots.length,
            onPageChanged: (index) => viewModel.updateMascotIndex(index),
            itemBuilder: (context, index) {
              return Image.asset(mascots[index], fit: BoxFit.contain);
            },
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(mascots.length, (index) {
            bool isActive = viewModel.currentMascotIndex == index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: isActive ? 30 : 10,
              height: 10,
              decoration: BoxDecoration(
                color: isActive ? AppColors.slideBubble : Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }
}