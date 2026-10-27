import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_colors.dart';
import '../../../core/app_assets.dart';
import 'package:talepuff_app/l10n/app_localizations.dart';
import 'package:talepuff_app/l10n/l10n_labels.dart';

class ChildProfileInfo extends StatelessWidget{
  final String name;
  final String age;
  final String email;
  final List<String> interests;

  const ChildProfileInfo({
    super.key,
    required this.name,
    required this.age,
    required this.email,
    required this.interests,
  });

  static String ageText(AppLocalizations l10n, String age) {
    final years = int.tryParse(age.trim());
    if (years == null || years <= 0) return '';
    return l10n.ageYears(years);
  }

  String _formatInterests(AppLocalizations l10n) {
    final prefix = l10n.profileIntro(name);
    if (interests.isEmpty) return '$prefix!';

    final labels = [for (final interest in interests) l10n.interestLabel(interest)];
    final String interestsText;
    if (labels.length == 1) {
      interestsText = l10n.profileLikes1(labels[0]);
    } else if (labels.length == 2) {
      interestsText = l10n.profileLikes2(labels[0], labels[1]);
    } else {
      interestsText = l10n.profileLikesMany(labels.sublist(0, labels.length - 1).join(', '), labels.last);
    }

    return '$prefix, $interestsText';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Text(
          [name, ageText(l10n, age)].where((part) => part.isNotEmpty).join(', '),
          style: const TextStyle(
            color: AppColors.darkPurple,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
        Text(
          _formatInterests(l10n),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.darkPurple,
            fontSize: 14,
            fontFamily: AppAssets.fontFamily,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          email,
          style: TextStyle(
            color: Colors.black.withValues(alpha: 0.4),
            fontSize: 12,
            fontFamily: AppAssets.fontFamily,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}