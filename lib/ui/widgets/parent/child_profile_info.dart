import 'package:flutter/material.dart';
import 'package:talepuff_app/core/app_colors.dart';
import '../../../core/app_assets.dart';

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

  String _formatInterests() {
    String prefix = "Hi, I'm $name";
    String interestsText;
    if (interests.isEmpty) return "$prefix!";

    if (interests.length == 1) {
      interestsText = "i like ${interests[0]}!";
    } else if (interests.length == 2) {
      interestsText = "i like ${interests[0]} and ${interests[1]}!";
    } else {
      String allButLast = interests.sublist(0, interests.length - 1).join(", ");
      interestsText = "i like $allButLast, and ${interests.last}!";
    }

    return "$prefix, $interestsText";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "$name, ${age}th",
          style: const TextStyle(
            color: AppColors.darkPurple,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
        Text(
          _formatInterests(),
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