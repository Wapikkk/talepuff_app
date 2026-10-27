import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/l10n_labels.dart';
import '../../view_models/settings/language_view_model.dart';

class LanguageSetting extends StatelessWidget {
  const LanguageSetting({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final preference = context.watch<LanguageViewModel>().preference;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.language,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.slideBubble,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          key: const Key('open-language'),
          contentPadding: EdgeInsets.zero,
          title: Text(
            l10n.languageLabel(preference),
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.darkPurple,
              fontFamily: AppAssets.fontFamily,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: AppColors.slideBubble),
          onTap: () => Navigator.pushNamed(context, '/language'),
        ),
        const Divider(height: 2, thickness: 2, color: AppColors.dividerLine),
      ],
    );
  }
}
