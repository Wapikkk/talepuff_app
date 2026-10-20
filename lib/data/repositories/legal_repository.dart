import 'package:flutter/services.dart';

import '../../core/app_config.dart';
import '../models/legal_document.dart';

class LegalRepository {
  LegalRepository({AssetBundle? bundle, String? contactEmail})
      : _bundle = bundle ?? rootBundle,
        _contactEmail = contactEmail ?? AppConfig.contactEmail;

  final AssetBundle _bundle;
  final String _contactEmail;

  static const _placeholder = '{{CONTACT_EMAIL}}';

  static String assetPath(LegalDocument document, LegalLanguage language) {
    return 'assets/legal/${document.name}_${language.name}.txt';
  }

  Future<List<LegalBlock>> load(LegalDocument document, LegalLanguage language) async {
    final raw = await _bundle.loadString(assetPath(document, language));
    final contact = _contactEmail.trim().isEmpty
        ? (language == LegalLanguage.id ? 'tim TalePuff' : 'the TalePuff team')
        : _contactEmail.trim();
    return LegalTextParser.parse(raw.replaceAll(_placeholder, contact));
  }
}
