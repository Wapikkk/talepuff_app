import 'package:flutter/material.dart';
import '../../widgets/story/audio_player_card.dart';
import '../../widgets/story/story_list_panel.dart';

class StoryView extends StatelessWidget {
  const StoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3B2E5A),
              Color(0xFFF9A88B),
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
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
    );
  }
}