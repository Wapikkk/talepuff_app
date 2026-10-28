import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talepuff_app/core/language_preference.dart';
import 'package:talepuff_app/data/services/app_info.dart';
import 'package:talepuff_app/ui/view_models/auth/login_view_model.dart';
import 'package:talepuff_app/ui/view_models/parents/child_info_view_model.dart';
import 'package:talepuff_app/ui/view_models/parents/update_settings_view_model.dart';
import 'package:talepuff_app/ui/view_models/settings/language_view_model.dart';
import 'package:talepuff_app/ui/view_models/startup_view_model.dart';
import 'package:talepuff_app/ui/views/child_info/child_info_view.dart';
import 'package:talepuff_app/ui/views/login/login_view.dart';
import 'package:talepuff_app/ui/views/settings/language_view.dart';
import 'package:talepuff_app/ui/views/settings/settings_view.dart';
import 'package:talepuff_app/ui/views/startup/startup_view.dart';
import 'package:talepuff_app/data/services/auth_gateway.dart';
import 'package:talepuff_app/data/services/auth_service.dart';

import '../data/language_test.dart' show FakeLanguageStore;
import '../support/fakes.dart';
import '../support/l10n.dart';

/// Aplikasi mini yang meniru `MyApp`: locale diambil dari LanguageViewModel (null = ikuti bahasa HP).
Widget languageApp(
  LanguageViewModel language, {
  required Widget home,
  Map<String, WidgetBuilder> routes = const {},
  List<SingleChildWidget> providers = const [],
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<LanguageViewModel>.value(value: language),
      ...providers,
    ],
    child: Consumer<LanguageViewModel>(
      builder: (_, current, __) => MaterialApp(
        locale: current.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routes: routes,
        home: home,
      ),
    ),
  );
}

/// Membuat "HP" berbahasa [locale] selama tes berjalan.
void phoneSpeaks(WidgetTester tester, Locale locale) {
  tester.platformDispatcher.localesTestValue = [locale];
  tester.platformDispatcher.localeTestValue = locale;
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  addTearDown(tester.platformDispatcher.clearLocaleTestValue);
}

/// Label formulir dibuat dengan RichText (agar tanda bintang wajib berwarna merah), yang tidak
/// ditemukan oleh `find.text` biasa; teksnya juga memuat " *".
Finder formLabel(String text) => find.textContaining(text, findRichText: true);

void tallScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(900, 2600);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('which language is shown', () {
    testWidgets('an Indonesian phone gets the Indonesian UI by default', (tester) async {
      phoneSpeaks(tester, const Locale('id', 'ID'));
      await tester.pumpWidget(languageApp(LanguageViewModel(store: FakeLanguageStore()), home: const LanguageView()));
      await tester.pumpAndSettle();

      expect(find.text('Bahasa'), findsOneWidget);
      expect(find.text('Ikuti perangkat'), findsOneWidget);
      expect(find.text('Language'), findsNothing);
    });

    testWidgets('an English phone gets English', (tester) async {
      phoneSpeaks(tester, const Locale('en', 'US'));
      await tester.pumpWidget(languageApp(LanguageViewModel(store: FakeLanguageStore()), home: const LanguageView()));
      await tester.pumpAndSettle();

      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Follow device'), findsOneWidget);
    });

    testWidgets('a phone language the app does not support falls back to English', (tester) async {
      phoneSpeaks(tester, const Locale('ja', 'JP'));
      await tester.pumpWidget(languageApp(LanguageViewModel(store: FakeLanguageStore()), home: const LanguageView()));
      await tester.pumpAndSettle();

      expect(find.text('Language'), findsOneWidget);
    });

    testWidgets('an explicit choice beats the phone language', (tester) async {
      phoneSpeaks(tester, const Locale('id', 'ID'));
      final language = LanguageViewModel(store: FakeLanguageStore(LanguagePreference.english));
      await language.load();

      await tester.pumpWidget(languageApp(language, home: const LanguageView()));
      await tester.pumpAndSettle();

      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Bahasa'), findsNothing);
    });
  });

  group('Language screen', () {
    testWidgets('choosing a language changes the UI at once, persists it, and "follow device" undoes it', (tester) async {
      phoneSpeaks(tester, const Locale('en', 'US'));
      final store = FakeLanguageStore();
      await tester.pumpWidget(languageApp(LanguageViewModel(store: store), home: const LanguageView()));
      await tester.pumpAndSettle();
      expect(find.text('Language'), findsOneWidget);

      await tester.tap(find.byKey(const Key('language-indonesian')));
      await tester.pumpAndSettle();

      expect(find.text('Bahasa'), findsOneWidget);
      expect(find.text('Ikuti perangkat'), findsOneWidget);
      expect(store.stored, LanguagePreference.indonesian);
      expect(
        find.descendant(of: find.byKey(const Key('language-indonesian')), matching: find.byIcon(Icons.check)),
        findsOneWidget,
        reason: 'the chosen option is marked',
      );

      await tester.tap(find.byKey(const Key('language-system')));
      await tester.pumpAndSettle();

      expect(find.text('Language'), findsOneWidget, reason: 'back to the phone (English)');
      expect(store.stored, LanguagePreference.system);
    });

    testWidgets('it tells parents that stories stay in simple English', (tester) async {
      phoneSpeaks(tester, const Locale('en', 'US'));
      await tester.pumpWidget(languageApp(LanguageViewModel(store: FakeLanguageStore()), home: const LanguageView()));
      await tester.pumpAndSettle();

      expect(find.text('Stories are always written in simple English.'), findsOneWidget);
    });
  });

  group('Settings', () {
    List<SingleChildWidget> providers() => [
          ChangeNotifierProvider(create: (_) => fakeTotemViewModel()),
          ChangeNotifierProvider(create: (_) => UpdateSettingsViewModel(repository: AccountFixture().repository)),
          Provider<AppInfo>.value(value: FakeAppInfo()),
        ];

    testWidgets('has a Language row that opens the picker; the whole screen then follows the new language',
        (tester) async {
      tallScreen(tester);
      phoneSpeaks(tester, const Locale('en', 'US'));
      await tester.pumpWidget(languageApp(
        LanguageViewModel(store: FakeLanguageStore()),
        home: const SettingsView(),
        routes: {'/language': (_) => const LanguageView()},
        providers: providers(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Follow device'), findsOneWidget);

      await tester.tap(find.byKey(const Key('open-language')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('language-indonesian')));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Pengaturan'), findsOneWidget);
      expect(find.text('Pengaturan Akun'), findsOneWidget);
      expect(find.text('Bahasa'), findsOneWidget);
      expect(find.text('Bahasa Indonesia'), findsOneWidget, reason: 'the row shows the current choice');
      expect(find.text('Batas Volume'), findsOneWidget);
      expect(find.text('Tentang'), findsOneWidget);
      expect(find.text('Keluar'), findsOneWidget);
      expect(find.text('Settings'), findsNothing);
    });
  });

  group('Login screen', () {
    Future<void> openLogin(WidgetTester tester, LanguagePreference preference) async {
      final language = LanguageViewModel(store: FakeLanguageStore(preference));
      await language.load();
      final login = LoginViewModel(repository: AuthFixture().repository);
      addTearDown(login.dispose);
      await tester.pumpWidget(languageApp(
        language,
        home: const LoginView(),
        providers: [ChangeNotifierProvider<LoginViewModel>.value(value: login)],
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('Indonesian: labels and the validation message are translated', (tester) async {
      tallScreen(tester);
      await openLogin(tester, LanguagePreference.indonesian);

      expect(find.text('Lanjutkan dengan Google'), findsOneWidget);
      expect(formLabel('Kata sandi'), findsOneWidget);
      expect(find.text('Ingat saya'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
      await tester.pump();

      expect(find.text('Email dan kata sandi wajib diisi!'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4)); // pesan hilang sendiri; mengosongkan timer
    });

    testWidgets('English: same screen, same message code, English text', (tester) async {
      tallScreen(tester);
      await openLogin(tester, LanguagePreference.english);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pump();

      expect(find.text('Email and Password are required!'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });
  });

  group('Child information screen (registration)', () {
    testWidgets('Indonesian labels, but the values sent to the server stay English', (tester) async {
      tallScreen(tester);
      final language = LanguageViewModel(store: FakeLanguageStore(LanguagePreference.indonesian));
      await language.load();
      final childInfo = ChildInfoViewModel(repository: AuthFixture().repository);
      addTearDown(childInfo.dispose);

      await tester.pumpWidget(languageApp(
        language,
        home: const ChildInfoView(),
        providers: [ChangeNotifierProvider<ChildInfoViewModel>.value(value: childInfo)],
      ));
      await tester.pumpAndSettle();

      expect(find.text('Informasi Anak'), findsOneWidget);
      expect(find.text('Info Dasar'), findsOneWidget);
      expect(formLabel('Nama Anak'), findsOneWidget);
      expect(formLabel('Jenis kelamin'), findsOneWidget);
      expect(formLabel('Minat'), findsOneWidget);
      expect(find.text('Sisa 3 pilihan'), findsOneWidget);

      await tester.tap(find.text('Laki-laki'));
      await tester.tap(find.text('Olahraga'));
      await tester.pump();

      expect(childInfo.selectedGender, 'male', reason: 'the value is not translated');
      expect(childInfo.selectedInterests, ['Sports'], reason: 'the value is not translated');
      expect(find.text('Sisa 2 pilihan'), findsOneWidget);

      await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan'));
      await tester.pump();
      expect(find.text('Silakan isi semua kolom yang wajib!'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });
  });

  group('Startup error screen', () {
    testWidgets('Indonesian: the server problem and its actions are in Indonesian', (tester) async {
      final f = AuthFixture(signedInUser: const AuthUser('uid-1', null));
      f.api.forcedLookup = const ProfileUnreachable('down');
      final startup = StartupViewModel(repository: f.repository);
      final language = LanguageViewModel(store: FakeLanguageStore(LanguagePreference.indonesian));
      await language.load();

      await tester.pumpWidget(languageApp(
        language,
        home: const StartupView(),
        routes: {'/landing': (_) => const Text('LANDING')},
        providers: [ChangeNotifierProvider<StartupViewModel>.value(value: startup)],
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('Tidak dapat menjangkau server'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);
      expect(find.text('Ubah alamat server'), findsOneWidget);
      expect(find.text('Gunakan akun lain'), findsOneWidget);
    });
  });
}
