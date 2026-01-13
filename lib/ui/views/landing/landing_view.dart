import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_assets.dart';
import 'package:talepuff_app/core/app_colors.dart';
import '../../widgets/get_started_btn.dart';
import '../../widgets/app_background.dart';
import '../../widgets/stars_overlay.dart';

class LandingView extends StatelessWidget{
  const LandingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
          child: Stack(
            children: [
              const StarsOverlay(),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 60),

                      const Text(
                        "Create your own story",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppAssets.fontFamily, // Quicksand
                        ),
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "Help your child learn English through stories they love",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: AppAssets.fontFamily,
                          height: 1.5,
                        ),
                      ),

                      const Spacer(),

                      GetStartedBtn(
                        onPressed: () {
                        },
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

                      const SizedBox(height: 70),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}