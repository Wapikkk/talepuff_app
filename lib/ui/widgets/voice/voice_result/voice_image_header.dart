import 'package:flutter/material.dart';
import '../../story/story_theme.dart';

class VoiceImageHeader extends StatelessWidget {
  final String theme;
  final bool isFavorite;
  final VoidCallback onBackPressed;
  final VoidCallback onFavoritePressed;

  const VoiceImageHeader({
    super.key,
    required this.theme,
    required this.isFavorite,
    required this.onBackPressed,
    required this.onFavoritePressed,
  });

  @override
  Widget build(BuildContext context) {
    final style = StoryThemeStyle.of(theme);

    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: style.color,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Center(
              child: style.iconAsset == null
                  ? const Icon(Icons.auto_stories, color: Colors.white70, size: 110)
                  : Image.asset(style.iconAsset!, width: 110, height: 110, color: style.iconColor),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    key: const Key('result-back'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: onBackPressed,
                  ),
                  IconButton(
                    key: const Key('result-favorite'),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: onFavoritePressed,
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
