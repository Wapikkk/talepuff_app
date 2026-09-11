import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/core/app_colors.dart';
import '../../view_models/story/story_filter_view_model.dart';

class StoryFilterTabs extends StatelessWidget{
  const StoryFilterTabs({super.key});

  Widget _buildTabButton(BuildContext context, String title, StoryFilterViewModel viewModel) {
    bool isSelected = viewModel.selectedTab == title;

    return GestureDetector(
      onTap: () => viewModel.setTab(title),
      child: Container(
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.topRight,
            colors: [
              AppColors.btnStory,
              AppColors.primaryPurple,
            ],
          ) : null,
          borderRadius: BorderRadius.circular(20),
        )
            : null,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StoryFilterViewModel>();

    if (viewModel.isSearching) {
      return TapRegion(
        onTapOutside: (event) {
          viewModel.toggleSearch(false);
          viewModel.searchFocusNode.unfocus();
        },
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            focusNode: viewModel.searchFocusNode,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Search stories...",
              hintStyle: TextStyle(color: Colors.white54),
              prefixIcon: Icon(Icons.search, color: Colors.white70),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _buildTabButton(context, "Recent", viewModel),
            const SizedBox(width: 16),
            _buildTabButton(context, "Favorites", viewModel),
            const SizedBox(width: 16),
            _buildTabButton(context, "Popular", viewModel),
          ],
        ),
        GestureDetector(
          onTap: () {
            viewModel.toggleSearch(true);
            viewModel.searchFocusNode.requestFocus();
          },
          child: const Icon(Icons.search, color: Colors.white),
        ),
      ],
    );
  }
}