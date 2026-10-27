import 'package:flutter/material.dart';
import '../../auth_flow.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/widgets/settings/about.dart';
import '../../../ui/widgets/settings/language_setting.dart';
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
    final l10n = AppLocalizations.of(context);
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

              const LanguageSetting(),
              const SizedBox(height: 15),

              const About(),
              const SizedBox(height: 15),

              TextButton(
                onPressed: () => AuthFlow.logout(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                ),
                child: Text(
                  l10n.logout,
                  style: const TextStyle(
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