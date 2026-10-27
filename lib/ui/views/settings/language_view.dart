import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../core/language_preference.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/l10n_labels.dart';
import '../../view_models/settings/language_view_model.dart';
import '../../widgets/update_settings/update_header_settings.dart';

class LanguageView extends StatelessWidget {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = context.watch<LanguageViewModel>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UpdateHeaderSettings(title: l10n.language),
              Text(
                l10n.languageStoriesNote,
                style: const TextStyle(
                  color: AppColors.slideBubble,
                  fontSize: 14,
                  fontFamily: AppAssets.fontFamily,
                ),
              ),
              const SizedBox(height: 12),
              for (final preference in LanguagePreference.values)
                _option(context, l10n, viewModel, preference),
            ],
          ),
        ),
      ),
    );
  }

  Widget _option(
    BuildContext context,
    AppLocalizations l10n,
    LanguageViewModel viewModel,
    LanguagePreference preference,
  ) {
    final selected = viewModel.preference == preference;
    return Column(
      children: [
        Semantics(
          button: true,
          selected: selected,
          child: ListTile(
            key: Key('language-${preference.name}'),
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
            trailing: selected ? const Icon(Icons.check, color: AppColors.btnSave) : null,
            onTap: () => viewModel.select(preference),
          ),
        ),
        const Divider(height: 2, thickness: 2, color: AppColors.dividerLine),
      ],
    );
  }
}
