import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../data/models/account_result.dart';
import '../../../data/models/story.dart';
import '../../view_models/navbar_view_model.dart';
import '../../view_models/story/story_filter_view_model.dart';
import '../shared/top_banner.dart';
import 'story_card.dart';
import 'story_filter_tabs.dart';

class StoryListPanel extends StatefulWidget {
  const StoryListPanel({super.key});

  @override
  State<StoryListPanel> createState() => _StoryListPanelState();
}

class _StoryListPanelState extends State<StoryListPanel> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients && _scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
        context.read<StoryFilterViewModel>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _openDetail(StorySummary story) async {
    final viewModel = context.read<StoryFilterViewModel>();
    final changed = await Navigator.pushNamed(context, '/story_detail', arguments: story.id);
    if (changed == true) viewModel.load();
  }

  Future<void> _toggleFavorite(StorySummary story) async {
    final viewModel = context.read<StoryFilterViewModel>();
    final overlay = TopBanner.overlayOf(context);
    final result = await viewModel.toggleFavorite(story);
    if (result is AccountFailure) {
      TopBanner.show(overlay, result.message, type: TopBannerType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StoryFilterViewModel>();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      decoration: const BoxDecoration(
        color: AppColors.darkPurple,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const StoryFilterTabs(),
          const SizedBox(height: 20),
          Expanded(child: _body(context, viewModel)),
        ],
      ),
    );
  }

  Widget _body(BuildContext context, StoryFilterViewModel viewModel) {
    if (viewModel.isLoading && viewModel.stories.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (viewModel.errorMessage != null && viewModel.stories.isEmpty) {
      return _buildMessage(
        icon: Icons.cloud_off,
        text: viewModel.errorMessage!,
        actionLabel: 'Try again',
        onAction: viewModel.load,
      );
    }
    if (viewModel.stories.isEmpty) return _buildEmptyState(context, viewModel);
    return _buildGrid(viewModel);
  }

  Widget _buildEmptyState(BuildContext context, StoryFilterViewModel viewModel) {
    if (viewModel.query.isNotEmpty) {
      return _buildMessage(icon: Icons.search_off, text: 'No stories match "${viewModel.query}".');
    }
    switch (viewModel.tab) {
      case StoryTab.favorites:
        return _buildMessage(icon: Icons.favorite_border, text: 'No favorite stories yet.\nTap the heart on a story to keep it here.');
      case StoryTab.popular:
        return _buildMessage(icon: Icons.trending_up, text: 'Stories you play the most will show up here.');
      case StoryTab.recent:
        return _buildMessage(
          icon: Icons.auto_stories,
          text: 'No story has been created.',
          actionLabel: "Let's create a story",
          onAction: () async => context.read<NavbarViewModel>().changeIndex(2),
        );
    }
  }

  Widget _buildMessage({
    required IconData icon,
    required String text,
    String? actionLabel,
    Future<void> Function()? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.white38),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF9A88B),
                  foregroundColor: AppColors.darkPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: AppAssets.fontFamily, fontSize: 14),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(StoryFilterViewModel viewModel) {
    return Column(
      children: [
        if (viewModel.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              viewModel.errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: viewModel.load,
            color: AppColors.darkPurple,
            child: GridView.builder(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 90),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75,
              ),
              itemCount: viewModel.stories.length,
              itemBuilder: (context, index) {
                final story = viewModel.stories[index];
                return StoryCard(
                  key: ValueKey(story.id),
                  story: story,
                  onTap: () => _openDetail(story),
                  onFavorite: () => _toggleFavorite(story),
                );
              },
            ),
          ),
        ),
        if (viewModel.isLoadingMore)
          const Padding(
            padding: EdgeInsets.only(bottom: 80, top: 8),
            child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
          ),
      ],
    );
  }
}
