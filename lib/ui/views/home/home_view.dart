import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/l10n/app_localizations.dart';
import 'package:talepuff_app/l10n/app_message_text.dart';
import '../../../data/models/app_message.dart';
import '../../../data/repositories/story_repository.dart';
import '../../totem_flow.dart';
import '../../view_models/parents/parent_view_model.dart';
import '../../view_models/parents/child_info_view_model.dart';
import '../../widgets/home/create_new_story_btn.dart';
import '../../widgets/home/play_last_story_btn.dart';
import '../../widgets/app_background.dart';
import '../../widgets/cloud_overlay.dart';
import '../../widgets/stars_overlay.dart';
import '../../widgets/home/home_greeting.dart';
import '../../widgets/home/mascot.dart';
import '../../widgets/shared/top_banner.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _playing = false;

  Future<void> _playLastStory() async {
    if (_playing) return;
    _playing = true;
    final overlay = TopBanner.overlayOf(context);
    final l10n = AppLocalizations.of(context);
    final repository = context.read<StoryRepository>();
    final childId = int.tryParse(context.read<ParentViewModel>().currentChildId ?? '');
    try {
      if (childId == null) {
        TopBanner.show(overlay, l10n.appMessage(AppMessage.childDataNotLoaded), type: TopBannerType.error);
        return;
      }
      final result = await repository.latestPlayable(childId);
      if (!mounted) return;
      switch (result) {
        case LatestStoryFound(:final story):
          await TotemFlow.playStory(context, story.id, title: story.title.isEmpty ? l10n.untitledStory : story.title);
        case LatestStoryNone():
          TopBanner.show(overlay, l10n.appMessage(AppMessage.noPlayableStory), type: TopBannerType.info);
        case LatestStoryFailed(:final message):
          TopBanner.show(overlay, l10n.appMessage(message), type: TopBannerType.error);
      }
    } finally {
      _playing = false;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChildInfoViewModel>().syncChildData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(

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
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Consumer<ChildInfoViewModel>(
                        builder: (context, childInfo, child) => Mascot(mascotId: childInfo.mascotId),
                      ),

                      const Spacer(),

                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PlayLastStoryBtn(onPressed: _playLastStory),
                            const SizedBox(height: 16),
                            const CreateNewStoryBtn(),
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
      ),
    );
  }
}