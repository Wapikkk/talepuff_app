import 'package:shared_preferences/shared_preferences.dart';

import '../../core/language_preference.dart';

abstract class LanguageStore {
  Future<LanguagePreference> load();
  Future<void> save(LanguagePreference preference);
}

class SharedPrefsLanguageStore implements LanguageStore {
  static const key = 'app_language';

  @override
  Future<LanguagePreference> load() async {
    final prefs = await SharedPreferences.getInstance();
    return LanguagePreference.fromCode(prefs.getString(key));
  }

  @override
  Future<void> save(LanguagePreference preference) async {
    final prefs = await SharedPreferences.getInstance();
    final code = preference.code;
    if (code == null) {
      await prefs.remove(key);
    } else {
      await prefs.setString(key, code);
    }
  }
}
