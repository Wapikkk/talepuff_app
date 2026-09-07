import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/story/story_filter_view_model.dart';
import '../../widgets/story/audio_player_card.dart';
import '../../widgets/story/story_list_panel.dart';
import '../../widgets/app_background.dart';
import '../../widgets/stars_overlay.dart';
import '../../widgets/cloud_overlay.dart';

class StoryView extends StatelessWidget {
  const StoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => StoryFilterViewModel(),
      child: Scaffold(

        body: AppBackground(
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                const StarsOverlay(),
                const CloudOverlay(),
                const Column(
                  children: [
                    AudioPlayerCard(),
                    Expanded(child: StoryListPanel()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}