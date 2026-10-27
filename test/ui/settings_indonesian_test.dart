import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/data/models/legal_document.dart';
import 'package:talepuff_app/data/repositories/feedback_repository.dart';
import 'package:talepuff_app/data/repositories/legal_repository.dart';
import 'package:talepuff_app/ui/view_models/parents/child_info_view_model.dart';
import 'package:talepuff_app/ui/view_models/parents/parent_view_model.dart';
import 'package:talepuff_app/ui/view_models/parents/update_settings_view_model.dart';
import 'package:talepuff_app/ui/view_models/settings/feedback_view_model.dart';
import 'package:talepuff_app/ui/views/settings/feedback_view.dart';
import 'package:talepuff_app/ui/views/settings/legal_view.dart';
import 'package:talepuff_app/ui/views/settings/update_mascot_view.dart';
import 'package:talepuff_app/ui/views/settings/update_password_view.dart';

import '../support/fakes.dart';
import '../support/l10n.dart';
import 'settings_screens_test.dart' show fakeLegal, settle;

const indonesian = Locale('id');

MaterialApp inIndonesian(Widget home) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: indonesian,
      home: home,
    );

void main() {
  group('Settings screens in Indonesian', () {
    testWidgets('Send Feedback shows Indonesian labels and an Indonesian validation message', (tester) async {
      final api = FakeFeedbackApi();
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => FeedbackViewModel(repository: FeedbackRepository(api: api, appInfo: FakeAppInfo())),
        child: inIndonesian(const FeedbackView()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Kirim Masukan'), findsOneWidget);
      expect(find.text('Masalah'), findsOneWidget);
      expect(find.text('Ide'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'hi');
      await tester.tap(find.text('Kirim'));
      await settle(tester);

      expect(find.textContaining('terlalu singkat'), findsOneWidget);
      expect(api.sent, isEmpty);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('Update Password shows the real minimum length in the hint and an Indonesian error', (tester) async {
      final f = AccountFixture();
      await tester.pumpWidget(ChangeNotifierProvider(
        create: (_) => UpdateSettingsViewModel(repository: f.repository),
        child: inIndonesian(const UpdatePasswordView()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Minimal 8 karakter, huruf dan angka'), findsOneWidget);

      await tester.tap(find.text('Ubah Kata Sandi').last);
      await settle(tester);

      expect(find.text('Kata sandi saat ini wajib diisi!'), findsOneWidget);
      expect(f.gateway.calls, isEmpty);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('Update Mascot translates the mascot names', (tester) async {
      final f = AccountFixture();
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UpdateSettingsViewModel(repository: f.repository)),
          ChangeNotifierProvider(create: (_) => ChildInfoViewModel(repository: AuthFixture().repository)),
          ChangeNotifierProvider(create: (_) => ParentViewModel(photos: fakePhotos(FakePhotoApi()))),
        ],
        child: inIndonesian(const UpdateMascotView()),
      ));
      await tester.pumpAndSettle();

      for (final name in ['Harimau Sumatra', 'Orangutan', 'Badak Jawa', 'Burung Cenderawasih']) {
        expect(find.text(name), findsOneWidget, reason: name);
      }
      expect(find.text('Ubah Maskot'), findsOneWidget);
    });
  });

  group('Terms and Privacy follow the app language', () {
    Widget app(Locale locale, LegalDocument document) => Provider<LegalRepository>.value(
          value: fakeLegal(),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,
            home: Builder(
              builder: (home) => Scaffold(
                body: ElevatedButton(
                  child: const Text('open'),
                  onPressed: () => Navigator.of(home).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const LegalView(),
                      settings: RouteSettings(name: '/legal', arguments: document),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

    testWidgets('an Indonesian app opens the Indonesian document first', (tester) async {
      await tester.pumpWidget(app(indonesian, LegalDocument.terms));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('1. Judul Indonesia'), findsOneWidget);
      expect(find.text('Syarat dan Ketentuan'), findsOneWidget);
    });

    testWidgets('an English app opens the English document first', (tester) async {
      await tester.pumpWidget(app(testLocale, LegalDocument.privacy));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('1. Privacy English'), findsOneWidget);
    });
  });
}
