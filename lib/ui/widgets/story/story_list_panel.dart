import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'story_filter_tabs.dart';
import 'story_card.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../view_models/story/story_filter_view_model.dart';
import '../../view_models/navbar_view_model.dart';

class StoryListPanel extends StatelessWidget {
  const StoryListPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StoryFilterViewModel>();
    final bool isEmpty = viewModel.stories.isEmpty;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      decoration: const BoxDecoration(
        color: AppColors.darkPurple,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          StoryFilterTabs(),
          const SizedBox(height: 20),
          Expanded(
            child: isEmpty? _buildEmptyState(context) : _buildGrid(viewModel.stories),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_stories, size: 64, color: Colors.white38),
          const SizedBox(height: 16),
          const Text(
            "No story has been created.",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<NavbarViewModel>().changeIndex(2);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF9A88B),
              foregroundColor: AppColors.darkPurple,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              "Let's create a story",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: AppAssets.fontFamily,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<String> stories){
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: stories.length,
      itemBuilder: (context, index) {
        return StoryCard(title: stories[index]);
      },
    );
  }
}