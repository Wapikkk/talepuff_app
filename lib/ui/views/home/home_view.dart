import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/home_view_model.dart';
import '../../view_models/child_info_view_model.dart';
import '../../widgets/home/create_new_story_btn.dart';
import '../../widgets/home/play_last_story_btn.dart';
import '../../widgets/app_background.dart';
import '../../widgets/cloud_overlay.dart';
import '../../widgets/stars_overlay.dart';
import '../../widgets/home/home_greeting.dart';
import '../../widgets/home/home_search_bar.dart';
import '../../widgets/home/mascot.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChildInfoViewModel>().syncChildData();
      context.read<HomeViewModel>().prepareHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
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
                    SizedBox(height: 20),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.11),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 30),
                          HomeGreeting(),
                          SizedBox(height: 16),
                          HomeSearchBar(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Consumer<HomeViewModel>(
                      builder: (context, hvm, child) {
                        return Mascot(mascotId: hvm.activeMascot);
                      },
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