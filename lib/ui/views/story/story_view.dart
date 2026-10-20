import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_assets.dart';
import '../../../data/repositories/story_repository.dart';
import '../../view_models/parents/child_info_view_model.dart';
import '../../view_models/parents/parent_view_model.dart';
import '../../view_models/story/story_filter_view_model.dart';
import '../../widgets/story/story_list_panel.dart';
import '../../widgets/app_background.dart';
import '../../widgets/stars_overlay.dart';
import '../../widgets/cloud_overlay.dart';

class StoryView extends StatelessWidget {
  const StoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => StoryFilterViewModel(
        repository: context.read<StoryRepository>(),
        childId: () => context.read<ParentViewModel>().currentChildId,
      )..load(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: AppBackground(
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                const StarsOverlay(),
                const CloudOverlay(),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "${context.watch<ChildInfoViewModel>().childName}'s stories",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: AppAssets.fontFamily,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(child: StoryListPanel()),
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
