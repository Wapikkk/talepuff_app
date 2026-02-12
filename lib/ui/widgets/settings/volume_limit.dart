import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../ui/view_models/settings_view_model.dart';
import '../../../core/app_colors.dart';
import '../../../core/app_assets.dart';

class VolumeLimit extends StatelessWidget {
  const VolumeLimit ({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsVM = context.watch<SettingsViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Volume Limit',
          style: TextStyle(
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