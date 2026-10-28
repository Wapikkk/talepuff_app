import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/data/models/story.dart';
import 'package:talepuff_app/data/repositories/totem_repository.dart';
import 'package:talepuff_app/ui/view_models/totem/totem_view_model.dart';
import 'package:talepuff_app/ui/widgets/story/totem_controls.dart';

import '../support/fakes.dart';
import '../support/l10n.dart';

const sentences = [
  StorySentence(100, 3600, 'Once upon a time, a small fox found a star.'),
  StorySentence(3650, 5600, 'It was very bright!'),
  StorySentence(5650, 7200, 'Did it glow?'),
];

void main() {
  group('StorySentence', () {
    test('parseAll keeps valid sentences and skips malformed ones', () {
      final parsed = StorySentence.parseAll([
        {'start': 0, 'end': 1500, 'text': ' Hello '},
        {'start': 'x', 'end': 10, 'text': 'bad time'},
        {'start': 5, 'end': 9, 'text': '   '},
        'not a map',
        {'start': 2000, 'end': 3000, 'text': 'There.'},
      ]);

      expect(parsed.map((s) => s.text), ['Hello', 'There.']);
      expect(parsed.first.startMs, 0);
      expect(parsed.first.endMs, 1500);
    });

    test('parseAll tolerates missing or wrong data (stories made before timings existed)', () {
      expect(StorySentence.parseAll(null), isEmpty);
      expect(StorySentence.parseAll('nope'), isEmpty);
      expect(StorySentence.parseAll(const []), isEmpty);
    });

    test('at() picks the sentence being read, holds through the pause between sentences', () {
      expect(StorySentence.at(sentences, 0)?.text, sentences[0].text, reason: 'before the first starts');
      expect(StorySentence.at(sentences, 2000)?.text, sentences[0].text);
      expect(StorySentence.at(sentences, 3620)?.text, sentences[0].text, reason: 'in the pause');
      expect(StorySentence.at(sentences, 3650)?.text, sentences[1].text);
      expect(StorySentence.at(sentences, 99999)?.text, sentences[2].text, reason: 'after the last');
      expect(StorySentence.at(const [], 1000), isNull);
    });

    test('StoryDetail reads the sentences from the backend answer', () {
      final detail = StoryDetail.fromJson({
        'id': 5,
        'content': 'x',
        'sentences': [
          {'start': 0, 'end': 100, 'text': 'A.'},
        ],
      });
      expect(detail.sentences.single.text, 'A.');
      expect(detail.copyWith(isFavorite: true).sentences, hasLength(1), reason: 'copyWith keeps them');
      expect(StoryDetail.fromJson({'id': 6}).sentences, isEmpty);
    });
  });

  group('audible position', () {
    test('counts the time since the last status and subtracts the buffer', () async {
      var now = DateTime(2026, 10, 28, 10, 0, 0);
      final api = FakeTotemApi()..current = pairedTotem(state: 'playing', storyId: 1);
      final vm = TotemViewModel(repository: TotemRepository(api: api), clock: () => now);
      await vm.refresh();

      expect(vm.audiblePositionMs, 5000 - TotemViewModel.bufferLagMs);

      now = now.add(const Duration(milliseconds: 1300));
      expect(vm.audiblePositionMs, 5000 + 1300 - TotemViewModel.bufferLagMs);
      vm.dispose();
    });

    test('does not move while paused, and stays inside the story', () async {
      var now = DateTime(2026, 10, 28, 10, 0, 0);
      final api = FakeTotemApi()..current = pairedTotem(state: 'paused', storyId: 1);
      final vm = TotemViewModel(repository: TotemRepository(api: api), clock: () => now);
      await vm.refresh();
      final frozen = vm.audiblePositionMs;

      now = now.add(const Duration(seconds: 30));
      expect(vm.audiblePositionMs, frozen);

      api.current = pairedTotem(state: 'playing', storyId: 1);
      await vm.refresh();
      now = now.add(const Duration(minutes: 5));
      expect(vm.audiblePositionMs, 36000, reason: 'never beyond the duration');
      vm.dispose();
    });
  });

  group('running text on the remote', () {
    Widget app(FakeTotemApi api, List<StorySentence> list, DateTime Function() clock) => ChangeNotifierProvider(
          create: (_) => TotemViewModel(
            repository: TotemRepository(api: api),
            pollInterval: const Duration(hours: 1),
            clock: clock,
          )..refresh(),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: testLocale,
            home: Scaffold(body: SingleChildScrollView(child: TotemControls(storyId: 1, sentences: list))),
          ),
        );

    Future<void> settle(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('shows the sentence being read, and the next one as time passes', (tester) async {
      var now = DateTime(2026, 10, 28, 10, 0, 0);
      // posisi dilaporkan 5 dtk dan buffer 0,8 dtk: terdengar di 4,2 dtk = kalimat kedua
      final api = FakeTotemApi()..current = pairedTotem(state: 'playing', storyId: 1);
      await tester.pumpWidget(app(api, sentences, () => now));
      await settle(tester);

      expect(find.text('It was very bright!'), findsOneWidget);

      now = now.add(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Did it glow?'), findsOneWidget);
    });

    testWidgets('a story without timings shows no sentence and does not break the remote', (tester) async {
      final api = FakeTotemApi()..current = pairedTotem(state: 'playing', storyId: 1);
      await tester.pumpWidget(app(api, const [], DateTime.now));
      await settle(tester);

      expect(find.byKey(const Key('totem-controls')), findsOneWidget);
      expect(find.text('It was very bright!'), findsNothing);
    });
  });
}
