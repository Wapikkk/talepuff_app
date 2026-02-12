import 'package:flutter/material.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';

class About extends StatelessWidget{
  const About ({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontFamily: AppAssets.fontFamily,
            color: AppColors.slideBubble,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),

        _buildAboutItem(
          title: 'Version',
          trailing: const Text(
            '1.0',
            style: TextStyle(
              color: AppColors.slideBubble,
              fontSize: 16,
              fontFamily: AppAssets.fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _buildAboutItem(
          title: 'Send Feedback',
          onTap: () {

          },
        ),
        _buildAboutItem(
          title: 'Terms and Conditions',
          onTap: () {

          },
        ),
        _buildAboutItem(
          title: 'Privacy Policy',
          onTap: () {

          },
        ),
      ],
    );
  }

  Widget _buildAboutItem({
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }){
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.darkPurple,
              fontWeight: FontWeight.bold,
              fontFamily: AppAssets.fontFamily,
            ),
          ),
          trailing: trailing ?? const Icon(
            Icons.chevron_right,
            color: AppColors.slideBubble,
          ),
          onTap: onTap,
        ),
        const Divider(
          height: 2,
          thickness: 2,
          color: AppColors.dividerLine,
        ),
      ],
    );
  }
}