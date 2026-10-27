import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> loadArb(String name) =>
    jsonDecode(File('lib/l10n/$name').readAsStringSync()) as Map<String, dynamic>;

Set<String> messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((key) => !key.startsWith('@')).toSet();

/// Nama parameter ICU di sebuah pesan: `{count}`, atau `{count, plural, ...}`.
Set<String> placeholders(String text) =>
    RegExp(r'\{(\w+)(?:,|\})').allMatches(text).map((m) => m.group(1)!).toSet();

void main() {
  final en = loadArb('app_en.arb');
  final id = loadArb('app_id.arb');

  test('both files declare their own locale', () {
    expect(en['@@locale'], 'en');
    expect(id['@@locale'], 'id');
  });

  test('English and Indonesian have exactly the same message keys', () {
    final onlyEn = messageKeys(en).difference(messageKeys(id));
    final onlyId = messageKeys(id).difference(messageKeys(en));

    expect(onlyEn, isEmpty, reason: 'missing in app_id.arb: $onlyEn');
    expect(onlyId, isEmpty, reason: 'missing in app_en.arb (the template): $onlyId');
  });

  test('no message is empty', () {
    for (final arb in [en, id]) {
      for (final key in messageKeys(arb).where((k) => !k.startsWith('@@'))) {
        expect((arb[key] as String).trim(), isNotEmpty, reason: key);
      }
    }
  });

  test('every message uses the same placeholders in both languages', () {
    for (final key in messageKeys(en).where((k) => !k.startsWith('@@'))) {
      expect(
        placeholders(id[key] as String),
        placeholders(en[key] as String),
        reason: 'placeholder mismatch in "$key"',
      );
    }
  });

  test('every placeholder used in a message is declared in the template metadata', () {
    for (final key in messageKeys(en).where((k) => !k.startsWith('@@'))) {
      final used = placeholders(en[key] as String);
      if (used.isEmpty) continue;

      final meta = en['@$key'] as Map<String, dynamic>?;
      expect(meta, isNotNull, reason: '"$key" has placeholders but no @$key metadata');
      final declared = (meta!['placeholders'] as Map<String, dynamic>).keys.toSet();
      expect(declared, used, reason: 'placeholders of "$key"');
    }
  });
}
