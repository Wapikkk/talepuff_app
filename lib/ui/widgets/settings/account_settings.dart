import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../view_models/parents/update_settings_view_model.dart';

class AccountSettings extends StatelessWidget{
  const AccountSettings ({super.key});

  @override
  Widget build(BuildContext context) {
    final canManageCredentials = context.watch<UpdateSettingsViewModel>().canManageCredentials;

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
          title: "Child's Name",
          onTap: () => Navigator.pushNamed(context, '/update_child_name'),
        ),
        if (canManageCredentials) ...[
          _buildSettingItem(
            context: context,
            title: 'Email',
            onTap: () => Navigator.pushNamed(context, '/update_email'),
          ),
          _buildSettingItem(
            context: context,
            title: 'Update Password',
            onTap: () => Navigator.pushNamed(context, '/update_password'),
          ),
        ],
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