import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/core/app_colors.dart';
import 'package:talepuff_app/core/app_assets.dart';
import 'package:talepuff_app/l10n/app_localizations.dart';
import 'package:talepuff_app/l10n/l10n_labels.dart';
import 'package:talepuff_app/ui/view_models/create_story/create_story_view_model.dart';

class CategorySelector extends StatefulWidget {
  const CategorySelector({super.key});

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  int? selectedIndex = -1;

  final List<Map<String, dynamic>> categories = [
    {"title": "Daily", "color": AppColors.logout, "icon": AppAssets.iconClearDay, "iconColor": Colors.white},
    {"title": "Friendship", "color": AppColors.friendshipBox, "icon": AppAssets.iconPets, "iconColor": Colors.white},
    {"title": "Adventure", "color": AppColors.inputField, "icon": AppAssets.iconRocketLaunch, "iconColor": Colors.white},
    {"title": "Feeling", "color": AppColors.feelingBox, "icon": AppAssets.iconExcited, "iconColor": AppColors.darkPurple},
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(categories.length, (index) {
        final cat = categories[index];
        final isSelected = selectedIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              if (selectedIndex == index) {
                selectedIndex = null;
                context.read<CreateStoryViewModel>().setCategory("");
              } else {
                selectedIndex = index;
                context.read<CreateStoryViewModel>().setCategory(cat["title"]);
              }
            });
          },
          child: AnimatedScale(
            scale: isSelected ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 70,
              height: 90,
              decoration: BoxDecoration(
                color: cat["color"],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: cat["color"].withOpacity(isSelected ? 0.5 : 0.2),
                    blurRadius: isSelected ? 15 : 5,
                    offset: Offset(0, isSelected ? 8 : 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(cat["icon"], color: cat["iconColor"], width: 32, height: 32),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        l10n.themeLabel(cat["title"]),
                        maxLines: 1,
                        style: TextStyle(
                          color: cat["iconColor"],
                          fontFamily: AppAssets.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
