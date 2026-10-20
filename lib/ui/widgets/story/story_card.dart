import 'package:flutter/material.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../core/relative_time.dart';
import '../../../data/models/story.dart';
import 'story_theme.dart';

class StoryCard extends StatelessWidget {
  final StorySummary story;
  final VoidCallback onTap;
  final VoidCallback onFavorite;
  final VoidCallback onDelete;
  final bool isDeleting;

  const StoryCard({
    super.key,
    required this.story,
    required this.onTap,
    required this.onFavorite,
    required this.onDelete,
    this.isDeleting = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = StoryThemeStyle.of(story.theme);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFDF7E4),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: style.color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: style.iconAsset == null
                          ? const Icon(
                              Icons.auto_stories,
                              color: Colors.white70,
                              size: 44,
                            )
                          : Image.asset(
                              style.iconAsset!,
                              width: 48,
                              height: 48,
                              color: style.iconColor,
                            ),
                    ),
                    if (story.lengthMinutes > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${story.lengthMinutes} min',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title.isEmpty ? 'Untitled story' : story.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontFamily: AppAssets.fontFamily,
                      color: AppColors.darkPurple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          RelativeTime.format(story.createdAt),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            key: Key('favorite-${story.id}'),
                            behavior: HitTestBehavior.opaque,
                            onTap: onFavorite,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(
                                story.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                size: 18,
                                color: story.isFavorite
                                    ? AppColors.dailyBox
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          GestureDetector(
                            key: Key('delete-${story.id}'),
                            behavior: HitTestBehavior.opaque,
                            onTap: isDeleting ? null : onDelete,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: isDeleting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: Padding(
                                        padding: EdgeInsets.all(2),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
