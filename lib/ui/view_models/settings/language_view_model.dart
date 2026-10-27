import 'dart:ui' show Locale;
import 'package:flutter/foundation.dart';
import '../../../core/language_preference.dart';
import '../../../data/services/language_store.dart';

class LanguageViewModel extends ChangeNotifier {
  LanguageViewModel({required LanguageStore store}) : _store = store;

  final LanguageStore _store;
  LanguagePreference _preference = LanguagePreference.system;

  LanguagePreference get preference => _preference;
  Locale? get locale => _preference.locale;

  Future<void> load() async {
    try {
      _preference = await _store.load();
    } catch (error) {
      debugPrint('[language] gagal membaca pilihan tersimpan, memakai bahasa perangkat: $error');
      _preference = LanguagePreference.system;
    }
    notifyListeners();
  }

  Future<void> select(LanguagePreference preference) async {
    if (preference == _preference) return;
    _preference = preference;
    notifyListeners();
    try {
      await _store.save(preference);
    } catch (error) {
      debugPrint('[language] gagal menyimpan pilihan: $error');
    }
  }
}
