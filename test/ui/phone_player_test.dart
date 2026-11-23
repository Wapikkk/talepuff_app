import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/data/models/app_message.dart';
import 'package:talepuff_app/data/models/story.dart';
import 'package:talepuff_app/ui/view_models/phone_player/phone_player_view_model.dart';
import 'package:talepuff_app/ui/views/story/story_detail_args.dart';
import 'package:talepuff_app/ui/views/story/story_detail_view.dart';

import '../support/fakes.dart';
import '../support/l10n.dart';
import 'story_screen_test.dart' show phoneTest, settle;

const url = 'http://172.20.10.14:8000/audio/story_1_Warm.wav';
const sentences = [
  StorySentence(0, 3000, 'Once upon a time.'),
  StorySentence(3100, 6000, 'A little fox ran home.'),
];

StoryDetail voiced({List<StorySentence> list = sentences}) => makeDetail(1, playbackUrl: url, sentences: list);

void main() {
  group('PhonePlayerViewModel', () {
    late FakeAudioPlayer audio;
    late PhonePlayerViewModel vm;

    setUp(() {
      audio = FakeAudioPlayer();
      vm = PhonePlayerViewModel(player: audio, loadTimeout: const Duration(milliseconds: 200));
    });
    tearDown(() => vm.dispose());

    test('plays the address the phone can reach, from the start', () async {
      await vm.play(voiced());

      expect(audio.loaded, [url]);
      expect(audio.calls, ['stop', 'load', 'play'], reason: 'anything that was playing is stopped first');
      expect(vm.state, PhonePlayback.playing);
      expect(vm.isActive(1), isTrue);
      expect(vm.isActive(2), isFalse);
    });

    test('follows the position and the length reported by the player', () async {
      await vm.play(voiced());
      audio.emitDuration(const Duration(seconds: 36));
      audio.emitPosition(const Duration(seconds: 4));
      await Future<void>.delayed(Duration.zero);

      expect(vm.duration, const Duration(seconds: 36));
      expect(vm.position, const Duration(seconds: 4));
    });

    test('pause and resume', () async {
      await vm.play(voiced());

      await vm.toggle();
      expect(vm.state, PhonePlayback.paused);
      expect(audio.calls.last, 'pause');

      await vm.toggle();
      expect(vm.state, PhonePlayback.playing);
      expect(audio.calls.last, 'play');
    });

    test('seeking stays inside the story', () async {
      await vm.play(voiced());
      audio.emitDuration(const Duration(seconds: 36));
      await Future<void>.delayed(Duration.zero);

      await vm.seek(const Duration(seconds: 10));
      expect(vm.position, const Duration(seconds: 10));
      expect(audio.calls.last, 'seek:10000');

      await vm.seek(const Duration(seconds: 99));
      expect(vm.position, const Duration(seconds: 36));
      await vm.seek(const Duration(seconds: -5));
      expect(vm.position, Duration.zero);
    });

    test('stop clears everything', () async {
      await vm.play(voiced());
      audio.emitPosition(const Duration(seconds: 4));
      await vm.stop();

      expect(vm.state, PhonePlayback.idle);
      expect(vm.storyId, isNull);
      expect(vm.position, Duration.zero);
      expect(vm.isActive(1), isFalse);
    });

    test('when the story ends the player lets go of it', () async {
      await vm.play(voiced());
      audio.finish();
      await Future<void>.delayed(Duration.zero);

      expect(vm.state, PhonePlayback.idle);
      expect(vm.isActive(1), isFalse);
    });

    test('a new story replaces the old one, and an older request that finishes late does not take over', () async {
      final gate = Completer<void>();
      audio.loadGate = gate;
      final first = vm.play(voiced());
      await Future<void>.delayed(Duration.zero);

      audio.loadGate = null;
      await vm.play(makeDetail(2, playbackUrl: 'http://172.20.10.14:8000/audio/story_2_Warm.wav'));
      gate.complete();
      await first;

      expect(vm.storyId, 2, reason: 'the late answer of story 1 is ignored');
      expect(vm.state, PhonePlayback.playing);
      expect(audio.calls.where((c) => c == 'play'), hasLength(1), reason: 'only the current request starts playing');
    });

    test('a story without a voice, or a server that cannot serve phones, is explained', () async {
      await vm.play(makeDetail(1));
      expect(vm.state, PhonePlayback.error);
      expect(vm.error, AppMessage.storyNoVoice);
      expect(audio.calls, isEmpty, reason: 'nothing is loaded');

      final hasAudioButNoAddress = StoryDetail.fromJson({'id': 3, 'audio_url': 'http://localhost:8000/audio/story_3_Warm.wav'});
      await vm.play(hasAudioButNoAddress);
      expect(vm.error, AppMessage.playbackUnavailable);
    });

    test('a failing or very slow load ends in an error that names the story', () async {
      audio.loadError = Exception('unreachable');
      await vm.play(voiced());
      expect(vm.state, PhonePlayback.error);
      expect(vm.error, AppMessage.audioPlaybackFailed);
      expect(vm.isActive(1), isTrue);

      audio
        ..loadError = null
        ..loadGate = Completer<void>();
      await vm.play(voiced());
      expect(vm.error, AppMessage.audioPlaybackFailed, reason: 'the 200 ms test timeout fires');
    });

    test('after a failure the same story can be tried again', () async {
      audio.loadError = Exception('down');
      await vm.play(voiced());
      audio.loadError = null;
      await vm.play(voiced());

      expect(vm.state, PhonePlayback.playing);
      expect(vm.error, isNull);
    });

    test('stopping after the view model is gone does nothing', () async {
      final other = PhonePlayerViewModel(player: FakeAudioPlayer());
      other.dispose();
      await other.stop();
    });
  });

  group('Listening on the phone from the story screen', () {
    Widget app(FakeStoryApi api, FakeAudioPlayer audio, {Object? arguments = const StoryDetailArgs(1)}) => MultiProvider(
          providers: [
            Provider.value(value: fakeStories(api)),
            ChangeNotifierProvider(create: (_) => fakeTotemViewModel()),
            ChangeNotifierProvider(create: (_) => fakePhonePlayer(audio)),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: testLocale,
            home: Builder(
              builder: (home) => Scaffold(
                body: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(home, '/story_detail', arguments: arguments),
                  child: const Text('open'),
                ),
              ),
            ),
            routes: {'/story_detail': (_) => const StoryDetailView()},
          ),
        );

    Future<void> open(WidgetTester tester, Widget widget) async {
      await tester.pumpWidget(widget);
      await tester.tap(find.text('open'));
      await settle(tester);
    }

    FakeStoryApi api({StoryDetail? detail}) => FakeStoryApi()..detail = detail ?? voiced();

    phoneTest('"Play on phone" plays the story and shows the player with time', (tester) async {
      final audio = FakeAudioPlayer();
      await open(tester, app(api(), audio));
      expect(find.byKey(const Key('phone-controls')), findsNothing, reason: 'nothing plays until asked');

      await tester.tap(find.byKey(const Key('play-on-phone')));
      await settle(tester);
      audio.emitDuration(const Duration(seconds: 36));
      audio.emitPosition(const Duration(seconds: 4));
      await tester.pump();

      expect(audio.loaded, [url]);
      expect(find.byKey(const Key('phone-controls')), findsOneWidget);
      expect(find.text('Playing on this phone'), findsOneWidget);
      expect(find.text('0:04 / 0:36'), findsOneWidget);
    });

    phoneTest('the sentence shown follows the sound', (tester) async {
      final audio = FakeAudioPlayer();
      await open(tester, app(api(), audio));
      await tester.tap(find.byKey(const Key('play-on-phone')));
      await settle(tester);

      audio.emitPosition(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Once upon a time.'), findsWidgets);

      audio.emitPosition(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('A little fox ran home.'), findsOneWidget);
    });

    phoneTest('pause, resume and stop from the player', (tester) async {
      final audio = FakeAudioPlayer();
      await open(tester, app(api(), audio));
      await tester.tap(find.byKey(const Key('play-on-phone')));
      await settle(tester);

      await tester.tap(find.byKey(const Key('phone-toggle')));
      await tester.pump();
      expect(audio.calls.last, 'pause');
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      await tester.tap(find.byKey(const Key('phone-toggle')));
      await tester.pump();
      expect(audio.calls.last, 'play');

      await tester.tap(find.byKey(const Key('phone-stop')));
      await tester.pump();
      expect(find.byKey(const Key('phone-controls')), findsNothing);
    });

    phoneTest('a story without a voice says so instead of failing silently', (tester) async {
      final audio = FakeAudioPlayer();
      await open(tester, app(api(detail: makeDetail(1)), audio));

      await tester.tap(find.byKey(const Key('play-on-phone')));
      await settle(tester);

      expect(find.byKey(const Key('phone-error')), findsOneWidget);
      expect(find.text('This story has no voice yet.'), findsOneWidget);
      expect(audio.loaded, isEmpty);
    });

    phoneTest('an audio that cannot be reached shows an error that can be retried', (tester) async {
      final audio = FakeAudioPlayer()..loadError = Exception('unreachable');
      await open(tester, app(api(), audio));

      await tester.tap(find.byKey(const Key('play-on-phone')));
      await settle(tester);
      expect(find.byKey(const Key('phone-error')), findsOneWidget);

      audio.loadError = null;
      await tester.tap(find.byKey(const Key('play-on-phone')));
      await settle(tester);

      expect(find.byKey(const Key('phone-error')), findsNothing);
      expect(find.byKey(const Key('phone-toggle')), findsOneWidget);
    });

    phoneTest('opened with autoPlay (from "Play Last Story") it starts by itself', (tester) async {
      final audio = FakeAudioPlayer();
      await open(tester, app(api(), audio, arguments: const StoryDetailArgs(1, autoPlay: true)));

      expect(audio.loaded, [url]);
      expect(find.byKey(const Key('phone-toggle')), findsOneWidget);
    });

    phoneTest('opened normally it does not play by itself', (tester) async {
      final audio = FakeAudioPlayer();
      await open(tester, app(api(), audio, arguments: 1));

      expect(audio.loaded, isEmpty);
    });

    phoneTest('leaving the story stops the sound', (tester) async {
      final audio = FakeAudioPlayer();
      await open(tester, app(api(), audio));
      await tester.tap(find.byKey(const Key('play-on-phone')));
      await settle(tester);
      audio.calls.clear();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await settle(tester);
      await tester.pump(const Duration(milliseconds: 50));

      expect(audio.calls, contains('stop'));
    });

    phoneTest('the totem button is still there, next to the phone button', (tester) async {
      await open(tester, app(api(), FakeAudioPlayer()));

      expect(find.byKey(const Key('play-on-totem')), findsOneWidget);
      expect(find.byKey(const Key('play-on-phone')), findsOneWidget);
    });

    phoneTest('speaks Indonesian', (tester) async {
      final audio = FakeAudioPlayer();
      await tester.pumpWidget(MultiProvider(
        providers: [
          Provider.value(value: fakeStories(api())),
          ChangeNotifierProvider(create: (_) => fakeTotemViewModel()),
          ChangeNotifierProvider(create: (_) => fakePhonePlayer(audio)),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('id'),
          home: Builder(
            builder: (home) => Scaffold(
              body: ElevatedButton(
                onPressed: () => Navigator.pushNamed(home, '/story_detail', arguments: 1),
                child: const Text('buka'),
              ),
            ),
          ),
          routes: {'/story_detail': (_) => const StoryDetailView()},
        ),
      ));
      await tester.tap(find.text('buka'));
      await settle(tester);

      expect(find.text('Putar di HP'), findsOneWidget);
      await tester.tap(find.byKey(const Key('play-on-phone')));
      await settle(tester);
      expect(find.text('Diputar di HP ini'), findsOneWidget);
    });
  });
}
