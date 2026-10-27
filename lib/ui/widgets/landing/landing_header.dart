import 'package:flutter/material.dart';
import '../../../core/app_assets.dart';
import '../../../l10n/app_localizations.dart';

class LandingHeader extends StatelessWidget {
  const LandingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Text(
          l10n.landingTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          l10n.landingSubtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: AppAssets.fontFamily,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}