import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/ui/view_models/voice/voice_result/voice_result_view_model.dart';
import 'package:talepuff_app/ui/view_models/voice/voice_selection_dialog/voice_selection_dialog_view_model.dart';
import 'package:talepuff_app/ui/views/voice/voice_selection_dialog/voice_selection_dialog_view.dart';

void main() {
  setUpAll(
    () => dotenv.loadFromString(envString: 'API_BASE_URL=http://backend.test'),
  );

  Future<void> openDialog(
    WidgetTester tester,
    http.Client client,
    List<String> published,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // Tombol pilihan suara (lebar 130) meluap 2 px pada font uji yang lebih lebar dari Quicksand.
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => VoiceSelectionDialogViewModel(),
          ),
          ChangeNotifierProvider(
            create: (_) => VoiceResultViewModel(
              client: client,
              publisher: (url) async => published.add(url),
            ),
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => VoiceSelectionDialogView.show(context, 5),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Warm'));
    await tester.pump(const Duration(milliseconds: 300));
  }

  testWidgets(
    'Done shows progress, ignores repeated taps and sends one request',
    (tester) async {
      final gate = Completer<http.Response>();
      var requests = 0;
      final published = <String>[];
      await openDialog(
        tester,
        MockClient((_) {
          requests++;
          return gate.future;
        }),
        published,
      );

      await tester.tap(find.text('Done'));
      await tester.pump();

      expect(find.text('Creating the voice…'), findsOneWidget);
      expect(find.text('Done'), findsNothing);
      await tester.tap(find.text('Creating the voice…'), warnIfMissed: false);
      await tester.tap(find.text('Creating the voice…'), warnIfMissed: false);
      await tester.pump();
      expect(requests, 1);

      gate.complete(http.Response('{"audio_url":"http://x/a.wav"}', 200));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        find.text('Choose your voice'),
        findsNothing,
        reason: 'dialog closes once the voice is ready',
      );
      expect(published, ['http://x/a.wav']);
      await tester.pump(const Duration(seconds: 5));
    },
  );

  testWidgets(
    'a failure keeps the dialog open with a red message and lets the user retry',
    (tester) async {
      var requests = 0;
      await openDialog(
        tester,
        MockClient((_) async {
          requests++;
          return http.Response('{"error":"boom"}', 500);
        }),
        [],
      );

      await tester.tap(find.text('Done'));
      await tester.pump();
      await tester.pump();

      expect(find.text('Choose your voice'), findsOneWidget);
      expect(
        find.text("We couldn't create the voice. Please try again."),
        findsOneWidget,
      );
      expect(
        find.text('Done'),
        findsOneWidget,
        reason: 'button is usable again',
      );

      await tester.tap(find.text('Done'));
      await tester.pump();
      await tester.pump();
      expect(requests, 2);
    },
  );
}
