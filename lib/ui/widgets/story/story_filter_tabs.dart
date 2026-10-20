import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/core/app_colors.dart';
import '../../../data/models/story.dart';
import '../../view_models/story/story_filter_view_model.dart';

class StoryFilterTabs extends StatelessWidget {
  const StoryFilterTabs({super.key});

  Widget _buildTabButton(StoryTab tab, StoryFilterViewModel viewModel) {
    final bool isSelected = viewModel.tab == tab;

    return GestureDetector(
      key: Key('tab-${tab.name}'),
      onTap: () => viewModel.setTab(tab),
      child: Container(
        padding: isSelected
            ? const EdgeInsets.symmetric(horizontal: 20, vertical: 8)
            : const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  colors: [AppColors.btnStory, AppColors.primaryPurple],
                ),
                borderRadius: BorderRadius.circular(20),
              )
            : null,
        child: Text(
          tab.label,
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
            onChanged: viewModel.search,
            textInputAction: TextInputAction.search,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Search stories...",
              hintStyle: TextStyle(color: Colors.white54),
              prefixIcon: Icon(Icons.search, color: Colors.white70),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                for (final tab in StoryTab.values) ...[
                  _buildTabButton(tab, viewModel),
                  if (tab != StoryTab.values.last) const SizedBox(width: 16),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          key: const Key('open-search'),
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
