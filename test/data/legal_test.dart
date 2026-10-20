import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talepuff_app/data/models/legal_document.dart';
import 'package:talepuff_app/data/repositories/legal_repository.dart';

class FakeBundle extends CachingAssetBundle {
  FakeBundle(this.files);
  final Map<String, String> files;

  @override
  Future<ByteData> load(String key) async {
    final text = files[key];
    if (text == null) throw FlutterError('Unable to load asset: $key');
    final bytes = Uint8List.fromList(utf8.encode(text));
    return ByteData.view(bytes.buffer);
  }
}

const sample = '''# Title
Last updated: today

## 1. First
A paragraph.
- one
- two

## 2. Second
Contact: {{CONTACT_EMAIL}}.
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LegalTextParser', () {
    test('turns the simple format into blocks and ignores blank lines', () {
      final blocks = LegalTextParser.parse(sample);

      expect(blocks.map((b) => b.runtimeType.toString()).toList(), [
        'LegalTitle', 'LegalParagraph', 'LegalHeading', 'LegalParagraph', 'LegalBullet', 'LegalBullet', 'LegalHeading', 'LegalParagraph',
      ]);
      expect((blocks[2] as LegalHeading).text, '1. First');
      expect((blocks[4] as LegalBullet).text, 'one');
    });

    test('handles Windows line endings', () {
      expect(LegalTextParser.parse('# A\r\n## B\r\n- c\r\n').length, 3);
    });
  });

  group('LegalRepository', () {
    test('substitutes the contact email', () async {
      final repository = LegalRepository(
        bundle: FakeBundle({LegalRepository.assetPath(LegalDocument.terms, LegalLanguage.en): sample}),
        contactEmail: 'help@talepuff.app',
      );

      final blocks = await repository.load(LegalDocument.terms, LegalLanguage.en);

      expect((blocks.last as LegalParagraph).text, 'Contact: help@talepuff.app.');
    });

    test('falls back to a readable phrase, in the document language, while no email is configured', () async {
      final files = {
        LegalRepository.assetPath(LegalDocument.terms, LegalLanguage.en): sample,
        LegalRepository.assetPath(LegalDocument.terms, LegalLanguage.id): sample,
      };
      final repository = LegalRepository(bundle: FakeBundle(files), contactEmail: '  ');

      final en = await repository.load(LegalDocument.terms, LegalLanguage.en);
      final id = await repository.load(LegalDocument.terms, LegalLanguage.id);

      expect((en.last as LegalParagraph).text, 'Contact: the TalePuff team.');
      expect((id.last as LegalParagraph).text, 'Contact: tim TalePuff.');
    });

    test('a missing asset fails loudly instead of showing an empty page', () async {
      final repository = LegalRepository(bundle: FakeBundle({}));
      await expectLater(repository.load(LegalDocument.privacy, LegalLanguage.id), throwsA(isA<FlutterError>()));
    });
  });

  group('the real policy files shipped with the app', () {
    final combos = [
      for (final doc in LegalDocument.values)
        for (final lang in LegalLanguage.values) (doc, lang),
    ];

    test('all four are bundled and load', () async {
      for (final (doc, lang) in combos) {
        final blocks = await LegalRepository().load(doc, lang);
        expect(blocks, isNotEmpty, reason: '$doc/$lang');
      }
    });

    test('contain no unfilled placeholders after loading', () async {
      for (final (doc, lang) in combos) {
        final text = (await LegalRepository().load(doc, lang))
            .map((b) => switch (b) {
                  LegalTitle(:final text) || LegalHeading(:final text) || LegalParagraph(:final text) || LegalBullet(:final text) => text,
                })
            .join('\n');
        expect(text.contains('{{'), isFalse, reason: '$doc/$lang');
      }
    });

    test('the English and Indonesian versions have the same structure (kept in sync)', () async {
      for (final doc in LegalDocument.values) {
        final en = await LegalRepository().load(doc, LegalLanguage.en);
        final id = await LegalRepository().load(doc, LegalLanguage.id);
        expect(
          id.map((b) => b.runtimeType).toList(),
          en.map((b) => b.runtimeType).toList(),
          reason: '$doc: same sections, paragraphs and bullets in the same order',
        );
      }
    });
  });
}
