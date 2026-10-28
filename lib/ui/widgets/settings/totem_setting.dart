import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../view_models/totem/totem_view_model.dart';

class TotemSetting extends StatelessWidget {
  const TotemSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = context.watch<TotemViewModel>();
    final summary = viewModel.isPaired ? l10n.totemLinkedTo(viewModel.deviceId ?? '') : l10n.totemNotLinked;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.totem,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.slideBubble,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          key: const Key('open-totem'),
          contentPadding: EdgeInsets.zero,
          title: Text(
            summary,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.darkPurple,
              fontFamily: AppAssets.fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.slideBubble),
          onTap: () => Navigator.pushNamed(context, '/totem'),
        ),
        const Divider(height: 2, thickness: 2, color: AppColors.dividerLine),
      ],
    );
  }
}
