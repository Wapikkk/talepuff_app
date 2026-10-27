import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talepuff_app/core/language_preference.dart';
import 'package:talepuff_app/core/validators.dart';
import 'package:talepuff_app/data/models/app_message.dart';
import 'package:talepuff_app/l10n/app_localizations.dart';
import 'package:talepuff_app/l10n/app_message_text.dart';
import 'package:talepuff_app/l10n/l10n_labels.dart';
import 'package:talepuff_app/ui/view_models/parents/child_info_view_model.dart';

import '../support/fakes.dart';

void main() {
  final en = lookupAppLocalizations(const Locale('en'));
  final id = lookupAppLocalizations(const Locale('id'));

  group('auth message codes', () {
    test('every code has a non-empty text in both languages', () {
      for (final message in AppMessage.values) {
        expect(en.appMessage(message).trim(), isNotEmpty, reason: 'en: $message');
        expect(id.appMessage(message).trim(), isNotEmpty, reason: 'id: $message');
      }
    });

    test('Indonesian texts are really translated, not copied from English', () {
      final identical = [
        for (final message in AppMessage.values)
          if (en.appMessage(message) == id.appMessage(message)) message,
      ];
      expect(identical, isEmpty, reason: 'same text in both languages: $identical');
    });

    test('messages with a number use the real limits from the validators', () {
      expect(en.appMessage(AppMessage.passwordRules), contains('${AuthValidators.minPasswordLength}'));
      expect(id.appMessage(AppMessage.passwordRules), contains('${AuthValidators.minPasswordLength}'));
      expect(en.appMessage(AppMessage.childNameTooLong), contains('${AuthValidators.maxChildNameLength}'));
      expect(id.appMessage(AppMessage.childNameTooLong), contains('${AuthValidators.maxChildNameLength}'));
    });

    test('a few messages read correctly (guards against swapped codes)', () {
      expect(en.appMessage(AppMessage.invalidCredentials), contains('Incorrect'));
      expect(id.appMessage(AppMessage.invalidCredentials), contains('salah'));
      expect(id.appMessage(AppMessage.credentialsRequired), 'Email dan kata sandi wajib diisi!');
    });
  });

  group('labels: only the label is translated, never the value sent to the server', () {
    test('every interest has an Indonesian label different from its key', () {
      final vm = ChildInfoViewModel(repository: AuthFixture().repository);
      addTearDown(vm.dispose);

      for (final interest in vm.allInterestData) {
        final key = interest['name']!;
        expect(en.interestLabel(key), key, reason: 'English label of $key');
        expect(id.interestLabel(key), isNot(key), reason: 'Indonesian label of $key');
      }
    });

    test('gender values map to labels, unknown values are shown as they are', () {
      expect(en.genderLabel('male'), 'Male');
      expect(en.genderLabel('female'), 'Female');
      expect(en.genderLabel('n/a'), 'N/A');
      expect(id.genderLabel('male'), 'Laki-laki');
      expect(id.genderLabel('female'), 'Perempuan');
      expect(id.genderLabel('n/a'), 'Tidak disebutkan');
      expect(id.genderLabel('other'), 'other');
      expect(id.interestLabel('Unknown'), 'Unknown');
    });

    test('language names are shown in their own language', () {
      for (final l10n in [en, id]) {
        expect(l10n.languageLabel(LanguagePreference.english), 'English');
        expect(l10n.languageLabel(LanguagePreference.indonesian), 'Bahasa Indonesia');
      }
      expect(en.languageLabel(LanguagePreference.system), 'Follow device');
      expect(id.languageLabel(LanguagePreference.system), 'Ikuti perangkat');
    });
  });

  group('plurals', () {
    test('English', () {
      expect(en.interestSlotsRemaining(0), 'No slots left');
      expect(en.interestSlotsRemaining(1), '1 slot remaining');
      expect(en.interestSlotsRemaining(3), '3 slots remaining');
    });

    test('Indonesian', () {
      expect(id.interestSlotsRemaining(0), 'Tidak ada sisa pilihan');
      expect(id.interestSlotsRemaining(1), 'Sisa 1 pilihan');
      expect(id.interestSlotsRemaining(3), 'Sisa 3 pilihan');
    });
  });
}
