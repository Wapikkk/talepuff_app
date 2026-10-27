import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/data/models/legal_document.dart';
import 'package:talepuff_app/data/repositories/feedback_repository.dart';
import 'package:talepuff_app/data/repositories/legal_repository.dart';
import 'package:talepuff_app/data/services/app_info.dart';
import 'package:talepuff_app/data/services/feedback_service.dart';
import 'package:talepuff_app/ui/view_models/auth/signup_view_model.dart';
import 'package:talepuff_app/ui/view_models/parents/child_info_view_model.dart';
import 'package:talepuff_app/ui/view_models/settings/feedback_view_model.dart';
import 'package:talepuff_app/ui/views/settings/feedback_view.dart';
import 'package:talepuff_app/ui/views/settings/legal_view.dart';
import 'package:talepuff_app/ui/widgets/settings/about.dart';
import 'package:talepuff_app/ui/widgets/signup/signup_input_form.dart';

import '../support/fakes.dart';
import '../data/legal_test.dart' show FakeBundle;
import '../support/l10n.dart';

/// Animasi baru mulai pada frame berikutnya, jadi dua pump: mulai, lalu selesai.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

const legalFiles = {
  'assets/legal/terms_en.txt': '# Terms and Conditions\nLast updated: today\n\n## 1. English heading\n- English bullet',
  'assets/legal/terms_id.txt': '# Syarat dan Ketentuan\nTerakhir diperbarui: hari ini\n\n## 1. Judul Indonesia\n- Butir Indonesia',
  'assets/legal/privacy_en.txt': '# Privacy Policy\nLast updated: today\n\n## 1. Privacy English\n- Data English',
  'assets/legal/privacy_id.txt': '# Kebijakan Privasi\nTerakhir diperbarui: hari ini\n\n## 1. Privasi Indonesia\n- Data Indonesia',
};

LegalRepository fakeLegal() => LegalRepository(bundle: FakeBundle(legalFiles), contactEmail: 'help@talepuff.app');

void main() {
  group('Send Feedback screen', () {
    Widget app(FeedbackApi api, {FakeAppInfo? info}) {
      return ChangeNotifierProvider(
        create: (_) => FeedbackViewModel(repository: FeedbackRepository(api: api, appInfo: info ?? FakeAppInfo())),
        child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: testLocale, 
          home: Builder(
            builder: (home) => Scaffold(
              body: ElevatedButton(
                child: const Text('open'),
                onPressed: () => Navigator.of(home).push(MaterialPageRoute<void>(builder: (_) => const FeedbackView())),
              ),
            ),
          ),
        ),
      );
    }

    Future<void> openForm(WidgetTester tester) async {
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    }

    testWidgets('sends the message, shows the thank-you banner and goes back', (tester) async {
      final api = FakeFeedbackApi();
      await tester.pumpWidget(app(api));
      await openForm(tester);

      await tester.tap(find.text('Bug'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'The audio stops after one minute');
      await tester.tap(find.text('Send'));
      await settle(tester);

      expect(api.sent, [
        {'category': 'bug', 'message': 'The audio stops after one minute', 'version': '1.0.0+1'},
      ]);
      expect(find.text('Thank you for your feedback!'), findsOneWidget);
      expect(find.text('open'), findsOneWidget, reason: 'returned to the previous screen');

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('a too-short message shows the red message and sends nothing', (tester) async {
      final api = FakeFeedbackApi();
      await tester.pumpWidget(app(api));
      await openForm(tester);

      await tester.enterText(find.byType(TextField), 'hi');
      await tester.tap(find.text('Send'));
      await settle(tester);

      expect(find.textContaining('too short'), findsOneWidget);
      expect(find.text('Thank you for your feedback!'), findsNothing);
      expect(api.sent, isEmpty);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('a server failure keeps the form and explains why', (tester) async {
      final api = FakeFeedbackApi()..error = const FeedbackApiException('limit', statusCode: 429);
      await tester.pumpWidget(app(api));
      await openForm(tester);

      await tester.enterText(find.byType(TextField), 'Another idea for stories');
      await tester.tap(find.text('Send'));
      await settle(tester);

      expect(find.textContaining('a lot of feedback'), findsOneWidget);
      expect(find.text('Send Feedback'), findsOneWidget, reason: 'still on the form');

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('the button is locked while sending, so a double tap sends once', (tester) async {
      final api = _SlowFeedbackApi();
      await tester.pumpWidget(app(api));
      await openForm(tester);

      await tester.enterText(find.byType(TextField), 'A message that is long enough');
      await tester.tap(find.text('Send'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget, reason: 'spinner while sending');
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull, reason: 'cannot be tapped again');

      api.finish();
      await settle(tester);
      expect(api.calls, 1);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });
  });

  group('About section', () {
    Widget app({String label = '1.0.0 (1)', required List<String> log}) {
      return MultiProvider(
        providers: [Provider<AppInfo>.value(value: FakeAppInfo(label: label))],
        child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: testLocale, 
          home: const Scaffold(body: SingleChildScrollView(child: About())),
          onGenerateRoute: (settings) {
            log.add('${settings.name}:${settings.arguments}');
            return MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('pushed')), settings: settings);
          },
        ),
      );
    }

    testWidgets('shows the real app version instead of a hard-coded one', (tester) async {
      await tester.pumpWidget(app(label: '2.3.4 (17)', log: []));
      await tester.pumpAndSettle();

      expect(find.text('2.3.4 (17)'), findsOneWidget);
      expect(find.text('1.0'), findsNothing);
    });

    testWidgets('each item opens its own screen', (tester) async {
      final log = <String>[];
      await tester.pumpWidget(app(log: log));
      await tester.pumpAndSettle();

      for (final title in ['Send Feedback', 'Terms and Conditions', 'Privacy Policy']) {
        await tester.tap(find.text(title));
        await tester.pumpAndSettle();
        tester.state<NavigatorState>(find.byType(Navigator)).pop();
        await tester.pumpAndSettle();
      }

      // Rute awal "/" memakai `home`, jadi tidak lewat onGenerateRoute dan tidak tercatat.
      expect(log, [
        '/feedback:null',
        '/legal:${LegalDocument.terms}',
        '/legal:${LegalDocument.privacy}',
      ]);
    });
  });

  group('Terms and Privacy screen', () {
    Widget app(LegalDocument document) {
      return Provider<LegalRepository>.value(
        value: fakeLegal(),
        child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: testLocale, 
          home: Builder(
            builder: (home) => Scaffold(
              body: ElevatedButton(
                child: const Text('open'),
                onPressed: () => Navigator.of(home).push(
                  MaterialPageRoute<void>(builder: (_) => const LegalView(), settings: RouteSettings(name: '/legal', arguments: document)),
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('shows the Terms and can switch language', (tester) async {
      await tester.pumpWidget(app(LegalDocument.terms));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('1. English heading'), findsOneWidget);
      expect(find.text('Terms and Conditions'), findsOneWidget);

      await tester.tap(find.text('Indonesia'));
      await tester.pumpAndSettle();

      expect(find.text('1. Judul Indonesia'), findsOneWidget);
      expect(find.text('1. English heading'), findsNothing);
      expect(find.text('Syarat dan Ketentuan'), findsOneWidget);
    });

    testWidgets('shows the Privacy Policy when asked for it', (tester) async {
      await tester.pumpWidget(app(LegalDocument.privacy));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('1. Privacy English'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.text('1. English heading'), findsNothing);
    });

    testWidgets('a document that fails to load says so instead of showing a blank page', (tester) async {
      await tester.pumpWidget(Provider<LegalRepository>.value(
        value: LegalRepository(bundle: FakeBundle({})),
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: testLocale, home: LegalView()),
      ));
      await tester.pumpAndSettle();

      expect(find.text('This document could not be loaded.'), findsOneWidget);
    });
  });

  group('sign-up form links', () {
    testWidgets('"terms of service" and "privacy policy" open the documents', (tester) async {
      final fixture = AuthFixture();
      final childInfo = ChildInfoViewModel(repository: fixture.repository);
      final opened = <Object?>[];

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: childInfo),
          ChangeNotifierProvider(create: (_) => SignUpViewModel(repository: fixture.repository, childInfoViewModel: childInfo)),
        ],
        child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: testLocale, 
          home: const Scaffold(body: SingleChildScrollView(child: SignUpInputForm())),
          onGenerateRoute: (settings) {
            if (settings.name == '/legal') opened.add(settings.arguments);
            return MaterialPageRoute<void>(builder: (_) => const Scaffold(body: Text('pushed')), settings: settings);
          },
        ),
      ));

      Future<void> tapSpan(String text) async {
        final richText = find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().contains('I accept the'));
        final root = tester.widget<RichText>(richText).text;
        late TextSpan target;
        root.visitChildren((span) {
          if (span is TextSpan && span.text == text) target = span;
          return true;
        });
        (target.recognizer! as TapGestureRecognizer).onTap!();
        await tester.pumpAndSettle();
        tester.state<NavigatorState>(find.byType(Navigator)).pop();
        await tester.pumpAndSettle();
      }

      await tapSpan('terms of service');
      await tapSpan('privacy policy');

      expect(opened, [LegalDocument.terms, LegalDocument.privacy]);
    });
  });
}

/// API yang baru selesai setelah [finish] dipanggil, untuk menguji status "sedang mengirim".
class _SlowFeedbackApi implements FeedbackApi {
  final _gate = Completer<void>();
  int calls = 0;

  void finish() => _gate.complete();

  @override
  Future<void> send({required String category, required String message, required String appVersion}) async {
    calls++;
    await _gate.future;
  }
}
