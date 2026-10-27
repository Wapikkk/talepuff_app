import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talepuff_app/core/validators.dart';
import 'package:talepuff_app/data/models/app_message.dart';
import 'package:talepuff_app/data/models/story_job.dart';
import 'package:talepuff_app/data/services/story_service.dart';
import 'package:talepuff_app/ui/view_models/create_story/create_story_view_model.dart';
import 'package:talepuff_app/ui/view_models/loading/loading_view_model.dart';
import 'package:talepuff_app/ui/view_models/navbar_view_model.dart';
import 'package:talepuff_app/ui/views/create_story/create_story_view.dart';
import 'package:talepuff_app/ui/views/voice/voice_result/voice_result_view.dart';

import '../support/fakes.dart';
import '../support/l10n.dart';

void phoneTest(
  String description,
  Future<void> Function(WidgetTester tester) body,
) {
  testWidgets(description, (tester) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);
    await body(tester);
  });
}

CreateStoryViewModel filled() => CreateStoryViewModel()
  ..setCategory('Adventure')
  ..setCharacterName('Aira')
  ..setStoryLength('5 Minutes')
  ..setVoiceTone('Warm');

void main() {
  group('character name', () {
    test(
      'accepts letters, spaces, apostrophes and hyphens, up to 30 characters',
      () {
        for (final good in ['Aira', "Mary-Ann O'Neil", ' Aira ', 'A' * 30]) {
          expect(AuthValidators.characterNameIssue(good), isNull, reason: good);
        }
      },
    );

    test('says what is wrong with a code', () {
      expect(AuthValidators.characterNameIssue(''), AppMessage.characterNameRequired);
      expect(AuthValidators.characterNameIssue('   '), AppMessage.characterNameRequired);
      expect(AuthValidators.characterNameIssue('A' * 31), AppMessage.childNameTooLong);
      for (final bad in ['Ai%ra', '1Aira', "'Aira", 'Aira!', 'Ai😀']) {
        expect(AuthValidators.characterNameIssue(bad), AppMessage.childNameInvalid, reason: bad);
      }
    });
  });

  group('Create form name error', () {
    setUp(() => SharedPreferences.setMockInitialValues({'active_child_id': 7}));

    testWidgets('a name that cannot be used stops here, before any long wait', (
      tester,
    ) async {
      await tester.pumpWidget(const SizedBox());
      final context = tester.element(find.byType(SizedBox));

      for (final bad in ['', '   ', 'Ai%ra', '1Aira', 'A' * 31]) {
        final viewModel = filled()..setCharacterName(bad);
        await viewModel.generateStory(context);
        expect(viewModel.nameError, isNotNull, reason: 'name "$bad"');
        expect(
          viewModel.isLoading,
          isFalse,
          reason: 'nothing was started for "$bad"',
        );
      }
    });

    testWidgets('a good name raises no name error', (tester) async {
      await tester.pumpWidget(const SizedBox());
      final context = tester.element(find.byType(SizedBox));
      final viewModel = filled()
        ..setCharacterName("Mary-Ann O'Neil")
        ..setVoiceTone('');

      await viewModel.generateStory(context);

      expect(viewModel.nameError, isNull);
      expect(viewModel.error, AppMessage.chooseMissing);
    });

    phoneTest(
      'the error is red, sits under the name field, and goes away when typing',
      (tester) async {
        final viewModel = filled()..setCharacterName('Ai%ra');
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: viewModel),
              ChangeNotifierProvider(create: (_) => NavbarViewModel()),
            ],
            child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: testLocale, home: Scaffold(body: CreateStoryView())),
          ),
        );
        await viewModel.generateStory(
          tester.element(find.byType(CreateStoryView)),
        );
        await tester.pump();

        final error = find.byKey(const Key('name-error'));
        expect(error, findsOneWidget);
        expect(tester.widget<Text>(error).style?.color, Colors.red);

        viewModel.setCharacterName('Aira');
        await tester.pump();
        expect(error, findsNothing);
      },
    );

    test('reset clears a leftover name error', () {
      final viewModel = filled()..setCharacterName('');
      viewModel.reset();
      expect(viewModel.nameError, isNull);
    });
  });

  group('notices after generating', () {
    LoadingViewModel viewModelFor(StoryJob job) {
      final api = FakeStoryApi()..jobScript.add(job);
      return LoadingViewModel(
        repository: fakeStories(api),
        pollInterval: const Duration(milliseconds: 1),
      );
    }

    StoryJob done({bool idea = false, bool name = false}) => StoryJob(
      id: 1,
      status: StoryJobStatus.done,
      story: makeDetail(5),
      ideaDropped: idea,
      nameReplaced: name,
    );

    test('says nothing when nothing was changed', () async {
      final viewModel = viewModelFor(done());
      await viewModel.start({});
      expect(viewModel.notice, isNull);
      viewModel.dispose();
    });

    test('explains each substitution, and both together', () async {
      for (final entry in {
        (idea: true, name: false): AppMessage.noticeIdeaDropped,
        (idea: false, name: true): AppMessage.noticeNameReplaced,
        (idea: true, name: true): AppMessage.noticeBothReplaced,
      }.entries) {
        final viewModel = viewModelFor(
          done(idea: entry.key.idea, name: entry.key.name),
        );
        await viewModel.start({});
        expect(viewModel.notice, entry.value, reason: '${entry.key}');
        viewModel.dispose();
      }
    });

    test('the job from the server carries the name flag', () {
      final job = StoryJob.fromJson({
        'id': 1,
        'status': 'done',
        'name_replaced': true,
      });
      expect(job.nameReplaced, isTrue);
      expect(job.ideaDropped, isFalse);
    });
  });

  group('result page', () {
    Future<void> open(
      WidgetTester tester,
      FakeStoryApi api, {
      bool favorite = false,
    }) async {
      await tester.pumpWidget(
        Provider.value(
          value: fakeStories(api),
          child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: testLocale, 
            home: VoiceResultView(
              story: makeDetail(
                5,
                content: 'Aira flew to the moon.',
                favorite: favorite,
              ),
              payload: const {'child_id': 7},
            ),
          ),
        ),
      );
      await tester.pump();
    }

    phoneTest(
      'shows the story and a themed cover instead of the old placeholder',
      (tester) async {
        await open(tester, FakeStoryApi());

        expect(find.text('Story 5'), findsOneWidget);
        expect(find.text('Aira flew to the moon.'), findsOneWidget);
        expect(find.textContaining('Image'), findsNothing);
        expect(find.text('Re-Generate'), findsOneWidget);
      },
    );

    phoneTest('the heart is saved and stays filled', (tester) async {
      final api = FakeStoryApi();
      await open(tester, api);
      Finder heart(IconData icon) => find.descendant(
        of: find.byKey(const Key('result-favorite')),
        matching: find.byIcon(icon),
      );
      expect(heart(Icons.favorite_border), findsOneWidget);

      await tester.tap(find.byKey(const Key('result-favorite')));
      await tester.pump();
      await tester.pump();

      expect(api.favoriteCalls, ['5:true']);
      expect(heart(Icons.favorite), findsOneWidget);
    });

    phoneTest(
      'an already favorite story starts filled, and tapping removes it',
      (tester) async {
        final api = FakeStoryApi();
        await open(tester, api, favorite: true);

        await tester.tap(find.byKey(const Key('result-favorite')));
        await tester.pump();
        await tester.pump();

        expect(api.favoriteCalls, ['5:false']);
        expect(
          find.descendant(
            of: find.byKey(const Key('result-favorite')),
            matching: find.byIcon(Icons.favorite_border),
          ),
          findsOneWidget,
        );
      },
    );

    phoneTest('a failed save rolls the heart back and says so in red', (
      tester,
    ) async {
      final api = FakeStoryApi()
        ..favoriteError = const StoryApiException('down', statusCode: 500);
      await open(tester, api);

      await tester.tap(find.byKey(const Key('result-favorite')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        find.descendant(
          of: find.byKey(const Key('result-favorite')),
          matching: find.byIcon(Icons.favorite_border),
        ),
        findsOneWidget,
      );
      expect(find.textContaining("Can't reach the server"), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(seconds: 1));
    });

    phoneTest('a second tap while saving is ignored', (tester) async {
      final api = FakeStoryApi()..favoriteGate = (Completer<void>());
      await open(tester, api);

      await tester.tap(find.byKey(const Key('result-favorite')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('result-favorite')));
      await tester.pump();
      api.favoriteGate!.complete();
      await tester.pump();
      await tester.pump();

      expect(api.favoriteCalls, ['5:true']);
    });
  });
}
