import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../core/relative_time.dart';
import '../../../data/models/account_result.dart';
import '../../../data/repositories/story_repository.dart';
import '../../view_models/story/story_detail_view_model.dart';
import '../../widgets/shared/top_banner.dart';
import '../../widgets/story/story_theme.dart';

class StoryDetailView extends StatelessWidget {
  const StoryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final storyId = ModalRoute.of(context)?.settings.arguments;

    return ChangeNotifierProvider(
      create: (context) {
        final viewModel = StoryDetailViewModel(repository: context.read<StoryRepository>());
        if (storyId is int) viewModel.load(storyId);
        return viewModel;
      },
      child: const _StoryDetailBody(),
    );
  }
}

class _StoryDetailBody extends StatelessWidget {
  const _StoryDetailBody();

  Future<void> _toggleFavorite(BuildContext context) async {
    final viewModel = context.read<StoryDetailViewModel>();
    final overlay = TopBanner.overlayOf(context);
    final result = await viewModel.toggleFavorite();
    if (result is AccountFailure) TopBanner.show(overlay, result.message, type: TopBannerType.error);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StoryDetailViewModel>();
    final story = viewModel.story;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, viewModel.favoriteChanged);
      },
      child: Scaffold(
        backgroundColor: AppColors.darkPurple,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context, viewModel.favoriteChanged),
                    ),
                    const Spacer(),
                    if (story != null)
                      IconButton(
                        key: const Key('detail-favorite'),
                        icon: Icon(
                          story.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: story.isFavorite ? AppColors.dailyBox : Colors.white,
                        ),
                        onPressed: () => _toggleFavorite(context),
                      ),
                  ],
                ),
              ),
              Expanded(child: _content(context, viewModel)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, StoryDetailViewModel viewModel) {
    final story = viewModel.story;
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (story == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            viewModel.errorMessage ?? 'This story could not be loaded.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent, fontSize: 15, fontFamily: AppAssets.fontFamily),
          ),
        ),
      );
    }

    final style = StoryThemeStyle.of(story.theme);
    final paragraphs = story.content.split(RegExp(r'\n\s*\n')).map((p) => p.trim()).where((p) => p.isNotEmpty);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      children: [
        Text(
          story.title.isEmpty ? 'Untitled story' : story.title,
          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, fontFamily: AppAssets.fontFamily),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (story.theme.isNotEmpty) _chip(story.theme, style.color, style.iconColor),
            for (final mood in story.moods) _chip(mood, Colors.white24, Colors.white),
            if (story.lengthMinutes > 0) _chip('${story.lengthMinutes} min', Colors.white24, Colors.white),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Created ${RelativeTime.format(story.createdAt).toLowerCase()}',
          style: const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: AppAssets.fontFamily),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            key: const Key('play-on-totem'),
            onPressed: () => TopBanner.show(
              TopBanner.overlayOf(context),
              'Playing on the totem is coming soon!',
              type: TopBannerType.info,
            ),
            icon: const Icon(Icons.speaker, color: Colors.white),
            label: const Text(
              'Play on totem',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: AppAssets.fontFamily),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.btnSave,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        for (final paragraph in paragraphs)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              paragraph,
              style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.55, fontFamily: AppAssets.fontFamily),
            ),
          ),
      ],
    );
  }

  Widget _chip(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)),
      child: Text(
        label,
        style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: AppAssets.fontFamily),
      ),
    );
  }
}
