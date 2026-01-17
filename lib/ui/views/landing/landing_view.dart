import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../widgets/landing/get_started_btn.dart';
import '../../widgets/landing/mascot_pager.dart';
import '../../widgets/landing/landing_header.dart';
import '../../widgets/app_background.dart';
import '../../widgets/stars_overlay.dart';
import '../../view_models/landing_view_model.dart';

class LandingView extends StatelessWidget{
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<LandingViewModel>(context, listen: false);

    return Scaffold(
      body: AppBackground(
          child: Stack(
            children: [
              const StarsOverlay(),
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 70),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30.0),
                      child: LandingHeader(),
                    ),

                    const Spacer(),
                    const MascotPager(),
                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        children: [
                          GetStartedBtn(
                            onPressed: () => Navigator.pushNamed(context, '/child_info'),
                          ),
                          const SizedBox(height: 20),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: AppAssets.fontFamily,
                                fontSize: 16,
                                color: AppColors.darkPurple,
                              ),
                              children: [
                                TextSpan(
                                  text: "Already have an account ? ",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                                TextSpan(
                                  text: "Login",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ],
          ),
      ),
    );
  }
}