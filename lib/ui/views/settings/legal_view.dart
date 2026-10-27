import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../data/models/legal_document.dart';
import '../../../data/repositories/legal_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../widgets/update_settings/update_header_settings.dart';

class LegalView extends StatefulWidget {
  const LegalView({super.key});

  @override
  State<LegalView> createState() => _LegalViewState();
}

class _LegalViewState extends State<LegalView> {
  LegalLanguage? _languageChoice;
  LegalDocument? _document;
  Future<List<LegalBlock>>? _blocks;

  LegalLanguage get _language => _languageChoice!;

  LegalLanguage _appLanguage() {
    return Localizations.localeOf(context).languageCode == 'id' ? LegalLanguage.id : LegalLanguage.en;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_document != null) return;
    _languageChoice = _appLanguage();
    final argument = ModalRoute.of(context)?.settings.arguments;
    _document = argument is LegalDocument ? argument : LegalDocument.terms;
    _reload();
  }

  void _reload() {
    _blocks = context.read<LegalRepository>().load(_document!, _language);
  }

  void _selectLanguage(LegalLanguage language) {
    if (language == _language) return;
    setState(() {
      _languageChoice = language;
      _reload();
    });
  }

  String get _title {
    final l10n = lookupAppLocalizations(Locale(_language.name));
    return _document == LegalDocument.privacy ? l10n.privacyPolicy : l10n.termsAndConditions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UpdateHeaderSettings(title: _title),
              Row(
                children: [
                  _languageChip('English', LegalLanguage.en),
                  const SizedBox(width: 10),
                  _languageChip('Indonesia', LegalLanguage.id),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: FutureBuilder<List<LegalBlock>>(
                  future: _blocks,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || snapshot.data == null) {
                      return Center(
                        child: Text(
                          AppLocalizations.of(context).legalLoadFailed,
                          style: const TextStyle(color: Colors.redAccent, fontFamily: AppAssets.fontFamily),
                        ),
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.only(bottom: 32),
                      children: [for (final block in snapshot.data!) _render(block)],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _languageChip(String label, LegalLanguage language) {
    final selected = _language == language;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => _selectLanguage(language),
      selectedColor: AppColors.btnSave,
      labelStyle: TextStyle(
        fontFamily: AppAssets.fontFamily,
        fontWeight: FontWeight.bold,
        color: selected ? Colors.white : AppColors.darkPurple,
      ),
    );
  }

  Widget _render(LegalBlock block) {
    const body = TextStyle(fontSize: 15, height: 1.45, color: AppColors.darkPurple, fontFamily: AppAssets.fontFamily);
    switch (block) {
      case LegalTitle():
        return const SizedBox.shrink();
      case LegalHeading(:final text):
        return Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 6),
          child: Text(text, style: body.copyWith(fontSize: 17, fontWeight: FontWeight.bold)),
        );
      case LegalParagraph(:final text):
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(text, style: body),
        );
      case LegalBullet(:final text):
        return Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('•  ', style: body),
              Expanded(child: Text(text, style: body)),
            ],
          ),
        );
    }
  }
}
