import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talepuff_app/core/language_preference.dart';
import 'package:talepuff_app/data/services/language_store.dart';
import 'package:talepuff_app/ui/view_models/settings/language_view_model.dart';

class FakeLanguageStore implements LanguageStore {
  FakeLanguageStore([this.stored = LanguagePreference.system]);

  LanguagePreference stored;
  int saves = 0;
  Object? loadError;
  Object? saveError;

  @override
  Future<LanguagePreference> load() async {
    if (loadError != null) throw loadError!;
    return stored;
  }

  @override
  Future<void> save(LanguagePreference preference) async {
    if (saveError != null) throw saveError!;
    stored = preference;
    saves++;
  }
}

void main() {
  group('LanguagePreference', () {
    test('maps to the locale that is forced on the app (null = follow the phone)', () {
      expect(LanguagePreference.system.locale, isNull);
      expect(LanguagePreference.english.locale, const Locale('en'));
      expect(LanguagePreference.indonesian.locale, const Locale('id'));
    });

    test('fromCode restores known codes and falls back to "follow the phone" for anything else', () {
      expect(LanguagePreference.fromCode('en'), LanguagePreference.english);
      expect(LanguagePreference.fromCode('id'), LanguagePreference.indonesian);
      expect(LanguagePreference.fromCode(null), LanguagePreference.system);
      for (final garbage in ['system', 'fr', '', 'EN', 'id-ID']) {
        expect(LanguagePreference.fromCode(garbage), LanguagePreference.system, reason: garbage);
      }
    });
  });

  group('SharedPrefsLanguageStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('nothing stored means "follow the phone"', () async {
      expect(await SharedPrefsLanguageStore().load(), LanguagePreference.system);
    });

    test('a saved choice survives a restart (a new store instance reads it back)', () async {
      await SharedPrefsLanguageStore().save(LanguagePreference.indonesian);
      expect(await SharedPrefsLanguageStore().load(), LanguagePreference.indonesian);

      await SharedPrefsLanguageStore().save(LanguagePreference.english);
      expect(await SharedPrefsLanguageStore().load(), LanguagePreference.english);
    });

    test('choosing "follow the phone" removes the stored choice instead of storing a marker', () async {
      final store = SharedPrefsLanguageStore();
      await store.save(LanguagePreference.indonesian);

      await store.save(LanguagePreference.system);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(SharedPrefsLanguageStore.key), isFalse);
      expect(await store.load(), LanguagePreference.system);
    });

    test('an unknown stored value is ignored', () async {
      SharedPreferences.setMockInitialValues({SharedPrefsLanguageStore.key: 'klingon'});
      expect(await SharedPrefsLanguageStore().load(), LanguagePreference.system);
    });
  });

  group('LanguageViewModel', () {
    test('starts on "follow the phone" with no forced locale', () {
      final vm = LanguageViewModel(store: FakeLanguageStore());
      expect(vm.preference, LanguagePreference.system);
      expect(vm.locale, isNull);
    });

    test('load applies the stored choice', () async {
      final vm = LanguageViewModel(store: FakeLanguageStore(LanguagePreference.indonesian));
      await vm.load();
      expect(vm.preference, LanguagePreference.indonesian);
      expect(vm.locale, const Locale('id'));
    });

    test('a store that cannot be read falls back to the phone language instead of crashing the app', () async {
      final store = FakeLanguageStore()..loadError = StateError('disk');
      final vm = LanguageViewModel(store: store);
      await vm.load();
      expect(vm.preference, LanguagePreference.system);
    });

    test('select applies immediately, notifies, and persists', () async {
      final store = FakeLanguageStore();
      final vm = LanguageViewModel(store: store);
      var notifications = 0;
      vm.addListener(() => notifications++);

      await vm.select(LanguagePreference.english);

      expect(vm.locale, const Locale('en'));
      expect(notifications, 1);
      expect(store.stored, LanguagePreference.english);
    });

    test('selecting the current choice does nothing (no rebuild, no write)', () async {
      final store = FakeLanguageStore(LanguagePreference.english);
      final vm = LanguageViewModel(store: store);
      await vm.load();
      var notifications = 0;
      vm.addListener(() => notifications++);

      await vm.select(LanguagePreference.english);

      expect(notifications, 0);
      expect(store.saves, 0);
    });

    test('if saving fails the choice still applies for this session', () async {
      final store = FakeLanguageStore()..saveError = StateError('disk full');
      final vm = LanguageViewModel(store: store);

      await vm.select(LanguagePreference.indonesian);

      expect(vm.preference, LanguagePreference.indonesian);
    });
  });
}
