import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/ui/view_models/landing_view_model.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';

class MascotPager extends StatefulWidget {
  const MascotPager({super.key});

  @override
  State<MascotPager> createState() => _MascotPagerState();
}

class _MascotPagerState extends State<MascotPager>{
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<LandingViewModel>();
      viewModel.startAutoplay(_pageController, 4);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<LandingViewModel>();
    final List<String> mascots = [
      AppAssets.mascotBadak,
      AppAssets.mascotHarimauSumatera,
      AppAssets.mascotBurung,
      AppAssets.mascotOrangUtan,
    ];

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            itemCount: mascots.length,
            onPageChanged: (index) => viewModel.updateIndex(index),
            itemBuilder: (context, index) {
              return Image.asset(mascots[index], fit: BoxFit.contain);
            },
          ),
        ),
        const SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(mascots.length, (index) {
            bool isActive = viewModel.currentIndex == index;
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