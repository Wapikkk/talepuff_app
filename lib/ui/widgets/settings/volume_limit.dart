import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../data/models/account_result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_message_text.dart';
import '../../view_models/totem/totem_view_model.dart';
import '../shared/top_banner.dart';

/// Batas volume totem. Disimpan di backend pada totem yang tertaut, jadi berlaku dari HP mana pun.
class VolumeLimit extends StatefulWidget {
  const VolumeLimit({super.key});

  @override
  State<VolumeLimit> createState() => _VolumeLimitState();
}

class _VolumeLimitState extends State<VolumeLimit> {
  double? _drag;

  Future<void> _save(double value) async {
    final totem = context.read<TotemViewModel>();
    final overlay = TopBanner.overlayOf(context);
    final l10n = AppLocalizations.of(context);
    final result = await totem.setVolumeLimit(value.round());
    if (result is AccountFailure) {
      TopBanner.show(overlay, l10n.appMessage(result.message), type: TopBannerType.error);
    }
    if (mounted) setState(() => _drag = null);
  }

  @override
  Widget build(BuildContext context) {
    final totem = context.watch<TotemViewModel>();
    final l10n = AppLocalizations.of(context);
    final enabled = totem.isPaired;
    final value = (_drag ?? totem.volumeLimit.toDouble()).clamp(0, 100).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
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
            const Spacer(),
            if (enabled)
              Text(
                '${value.round()}%',
                key: const Key('volume-limit-value'),
                style: const TextStyle(color: AppColors.slideBubble, fontFamily: AppAssets.fontFamily),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 8,
            activeTrackColor: AppColors.darkPurple,
            inactiveTrackColor: AppColors.inactiveVolumeLimit,
            thumbColor: AppColors.darkPurple,
            disabledActiveTrackColor: AppColors.inactiveVolumeLimit,
            disabledThumbColor: AppColors.inactiveVolumeLimit,
            overlayColor: AppColors.darkPurple.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
          ),
          child: Slider(
            key: const Key('volume-limit-slider'),
            value: value,
            max: 100,
            divisions: 20,
            onChanged: enabled ? (v) => setState(() => _drag = v) : null,
            onChangeEnd: enabled ? _save : null,
          ),
        ),
        if (!enabled)
          Text(
            l10n.volumeLimitNeedsTotem,
            key: const Key('volume-limit-hint'),
            style: const TextStyle(color: AppColors.slideBubble, fontSize: 13, fontFamily: AppAssets.fontFamily),
          ),
      ],
    );
  }
}
