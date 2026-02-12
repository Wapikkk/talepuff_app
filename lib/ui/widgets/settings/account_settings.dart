import 'package:flutter/material.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';

class AccountSettings extends StatelessWidget{
  const AccountSettings ({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.slideBubble,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
        const SizedBox(height: 8),

        _buildSettingItem(
          context: context,
          title: 'Username',
          onTap: () {

          },
        ),
        _buildSettingItem(
          context: context,
          title: 'Email',
          onTap: () {

          },
        ),
        _buildSettingItem(
          context: context,
          title: 'Update Password',
          onTap: () {

          },
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required BuildContext context,
    required String title,
    required VoidCallback onTap,
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
              fontFamily: AppAssets.fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: const Icon(
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