import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../view_models/parents/settings_view_model.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_assets.dart';
import '../../../l10n/app_localizations.dart';

class VolumeLimit extends StatelessWidget {
  const VolumeLimit ({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsVM = context.watch<SettingsViewModel>();
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.volumeLimit,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.darkPurple,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
        const SizedBox(height: 8),

        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            activeTrackColor: AppColors.darkPurple,
            inactiveTrackColor: AppColors.inactiveVolumeLimit,
            thumbColor: AppColors.darkPurple,
            overlayColor: AppColors.darkPurple.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
          ),
          child: Slider(
            value: settingsVM.volumeLimit,
            onChanged: (value) {
              settingsVM.updateVolume(value);
            },
          ),
        ),
      ],
    );
  }
}