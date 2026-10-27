import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../data/models/account_result.dart';
import '../../../data/models/story.dart';
import '../../view_models/navbar_view_model.dart';
import '../../view_models/story/story_filter_view_model.dart';
import '../shared/top_banner.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_message_text.dart';
import 'delete_story_dialog.dart';
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
      if (_scroll.hasClients &&
          _scroll.position.pixels >= _scroll.position.maxScrollExtent - 300) {
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
    final changed = await Navigator.pushNamed(
      context,
      '/story_detail',
      arguments: story.id,
    );
    if (changed == true) viewModel.load();
  }

  Future<void> _toggleFavorite(StorySummary story) async {
    final viewModel = context.read<StoryFilterViewModel>();
    final overlay = TopBanner.overlayOf(context);
    final l10n = AppLocalizations.of(context);
    final result = await viewModel.toggleFavorite(story);
    if (result is AccountFailure) {
      TopBanner.show(overlay, l10n.appMessage(result.message), type: TopBannerType.error);
    }
  }

  Future<void> _confirmDelete(StorySummary story) async {
    final viewModel = context.read<StoryFilterViewModel>();
    final overlay = TopBanner.overlayOf(context);
    final l10n = AppLocalizations.of(context);
    final confirmed = await DeleteStoryDialog.confirm(
      context,
      story.title.isEmpty ? l10n.untitledStory : story.title,
    );
    if (!confirmed) return;

    final result = await viewModel.deleteStory(story);
    if (result is AccountSuccess) {
      TopBanner.show(overlay, l10n.appMessage(result.message));
    } else if (result is AccountFailure) {
      TopBanner.show(overlay, l10n.appMessage(result.message), type: TopBannerType.error);
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
    final l10n = AppLocalizations.of(context);
    if (viewModel.isLoading && viewModel.stories.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    if (viewModel.error != null && viewModel.stories.isEmpty) {
      return _buildMessage(
        icon: Icons.cloud_off,
        text: l10n.appMessage(viewModel.error!),
        actionLabel: l10n.tryAgain,
        onAction: viewModel.load,
      );
    }
    if (viewModel.stories.isEmpty) return _buildEmptyState(context, viewModel);
    return _buildGrid(context, viewModel);
  }

  Widget _buildEmptyState(
    BuildContext context,
    StoryFilterViewModel viewModel,
  ) {
    final l10n = AppLocalizations.of(context);
    if (viewModel.query.isNotEmpty) {
      return _buildMessage(
        icon: Icons.search_off,
        text: l10n.noStoriesMatch(viewModel.query),
      );
    }
    switch (viewModel.tab) {
      case StoryTab.favorites:
        return _buildMessage(
          icon: Icons.favorite_border,
          text: l10n.noFavorites,
        );
      case StoryTab.popular:
        return _buildMessage(
          icon: Icons.trending_up,
          text: l10n.noPopular,
        );
      case StoryTab.recent:
        return _buildMessage(
          icon: Icons.auto_stories,
          text: l10n.noStories,
          actionLabel: l10n.createFirstStory,
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
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF9A88B),
                  foregroundColor: AppColors.darkPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: AppAssets.fontFamily,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context, StoryFilterViewModel viewModel) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        if (viewModel.error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              l10n.appMessage(viewModel.error!),
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
                  onDelete: () => _confirmDelete(story),
                  isDeleting: viewModel.isDeleting(story.id),
                );
              },
            ),
          ),
        ),
        if (viewModel.isLoadingMore)
          const Padding(
            padding: EdgeInsets.only(bottom: 80, top: 8),
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
