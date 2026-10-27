import 'dart:ui' show Locale;

enum LanguagePreference {
  system(null),
  english('en'),
  indonesian('id');

  const LanguagePreference(this.code);

  final String? code;

  Locale? get locale => code == null ? null : Locale(code!);

  static LanguagePreference fromCode(String? code) =>
      values.firstWhere((preference) => preference.code == code, orElse: () => system);
}
