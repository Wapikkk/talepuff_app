import 'package:flutter/material.dart';
import '../../widgets/home/create_new_story_btn.dart';
import '../../widgets/home/play_last_story_btn.dart';
import '../../widgets/app_background.dart';
import '../../widgets/cloud_overlay.dart';
import '../../widgets/stars_overlay.dart';
import '../../widgets/home/home_greeting.dart';
import '../../widgets/home/home_search_bar.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      resizeToAvoidBottomInset: false,
      extendBody: true,

      body: AppBackground(
        child: Stack(
          children: [
            const StarsOverlay(),
            const CloudOverlay(),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 50),
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.78,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const HomeGreeting(),
                            const SizedBox(height: 16),
                            const HomeSearchBar(),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(),

                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PlayLastStoryBtn(
                            onPressed: () {
                            },
                          ),
                          const SizedBox(height: 16),
                          CreateNewStoryBtn(
                            onPressed: () {
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
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