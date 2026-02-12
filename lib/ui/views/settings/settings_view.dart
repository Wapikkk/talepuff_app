import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ui/view_models/login_view_model.dart';
import '../../../ui/widgets/settings/about.dart';
import '../../../ui/widgets/settings/volume_limit.dart';
import '../../../ui/widgets/settings/account_settings.dart';
import '../../../ui/widgets/settings/settings_header.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_assets.dart';

class SettingsView extends StatefulWidget{
  const SettingsView ({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SettingsHeader(),
              const SizedBox(height: 20),

              const AccountSettings(),
              const SizedBox(height: 15),

              const VolumeLimit(),
              const SizedBox(height: 15),

              const About(),
              const SizedBox(height: 15),

              TextButton(
                onPressed: () {
                  context.read<LoginViewModel>().logout(context);
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.dailyBox,
                    fontSize: 18,
                    fontFamily: AppAssets.fontFamily,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}