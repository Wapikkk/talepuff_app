import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talepuff_app/core/story_defaults.dart';
import 'package:talepuff_app/data/models/story_job.dart';
import 'package:talepuff_app/data/services/story_service.dart';
import 'package:talepuff_app/ui/view_models/create_story/create_story_view_model.dart';
import 'package:talepuff_app/ui/view_models/loading/loading_view_model.dart';
import 'package:talepuff_app/ui/view_models/navbar_view_model.dart';
import 'package:talepuff_app/ui/views/create_story/create_story_view.dart';
import 'package:talepuff_app/ui/views/loading_screen/loading_screen_view.dart';

import '../support/fakes.dart';

const payload = {'child_id': 7, 'character_name': 'Aira', 'voice_tone': 'Warm'};

StoryJob job(
  StoryJobStatus status, {
  bool withStory = false,
  String errorCode = '',
  bool ideaDropped = false,
}) {
  return StoryJob(
    id: 11,
    status: status,
    story: withStory ? makeDetail(5, content: 'Aira flew to the moon.') : null,
    errorCode: errorCode,
    ideaDropped: ideaDropped,
  );
}

const unreachable = StoryApiException('Cannot reach the server');

LoadingViewModel viewModelFor(FakeStoryApi api, {int maxPollFailures = 5}) {
  return LoadingViewModel(
    repository: fakeStories(api),
    pollInterval: const Duration(milliseconds: 1),
    maxPollFailures: maxPollFailures,
  );
}

Future<void> until(LoadingViewModel viewModel, bool Function() done) async {
  for (var i = 0; i < 500 && !done(); i++) {
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
}

void phoneTest(
  String description,
  Future<void> Function(WidgetTester tester) body,
) {
  testWidgets(description, (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await body(tester);
  });
}

void main() {
  group('LoadingViewModel', () {
    test(
      'follows the real stages the backend reports, then finishes with the story',
      () async {
        final api = FakeStoryApi()
          ..jobScript.addAll([
            job(StoryJobStatus.queued),
            job(StoryJobStatus.writingStory),
            job(StoryJobStatus.creatingVoice, withStory: true),
            job(StoryJobStatus.done, withStory: true),
          ]);
        final viewModel = viewModelFor(api);
        final stages = <LoadingStage>[];
        viewModel.addListener(() {
          if (stages.isEmpty || stages.last != viewModel.stage) {
            stages.add(viewModel.stage);
          }
        });
        var created = 0;

        await viewModel.start(payload, onCreated: () => created++);

        expect(stages, [
          LoadingStage.starting,
          LoadingStage.writing,
          LoadingStage.voice,
          LoadingStage.done,
        ]);
        expect(viewModel.story?.content, 'Aira flew to the moon.');
        expect(viewModel.isWorking, isFalse);
        expect(api.startedJobs, [payload]);
        expect(created, 1, reason: 'the form is cleared once the job exists');
        expect(api.jobCalls, everyElement(11));
        viewModel.dispose();
      },
    );

    test(
      'a job that could not even start explains why and keeps the form (no onCreated)',
      () async {
        final api = FakeStoryApi()
          ..startError = const StoryApiException('down', statusCode: 400);
        final viewModel = viewModelFor(api);
        var created = 0;

        await viewModel.start(payload, onCreated: () => created++);

        expect(viewModel.stage, LoadingStage.failed);
        expect(viewModel.failureMessage, contains("didn't understand"));
        expect(viewModel.canRetry, isTrue);
        expect(created, 0);
        viewModel.dispose();
      },
    );

    test(
      'each failure code from the backend gets its own plain message',
      () async {
        final expectations = {
          'ai_unavailable': "The story service isn't running right now",
          'ai_failed': "We couldn't write the story this time",
          'save_failed': "We couldn't save the story",
          'interrupted': 'The story was interrupted',
          'something_new': 'Something went wrong',
        };
        for (final entry in expectations.entries) {
          final api = FakeStoryApi()
            ..jobScript.add(job(StoryJobStatus.failed, errorCode: entry.key));
          final viewModel = viewModelFor(api);

          await viewModel.start(payload);

          expect(viewModel.stage, LoadingStage.failed, reason: entry.key);
          expect(
            viewModel.failureMessage,
            contains(entry.value),
            reason: entry.key,
          );
          expect(viewModel.canRetry, isTrue, reason: entry.key);
          expect(viewModel.storyWasSaved, isFalse, reason: entry.key);
          viewModel.dispose();
        }
      },
    );

    test(
      'when only the voice fails the story is kept and retrying is not offered',
      () async {
        final api = FakeStoryApi()
          ..jobScript.add(
            job(
              StoryJobStatus.failed,
              withStory: true,
              errorCode: 'voice_failed',
            ),
          );
        final viewModel = viewModelFor(api);

        await viewModel.start(payload);

        expect(viewModel.failureMessage, contains('Your story was saved'));
        expect(viewModel.storyWasSaved, isTrue);
        expect(viewModel.canRetry, isFalse);
        viewModel.dispose();
      },
    );

    test('remembers that the idea was not used', () async {
      final api = FakeStoryApi()
        ..jobScript.add(
          job(StoryJobStatus.done, withStory: true, ideaDropped: true),
        );
      final viewModel = viewModelFor(api);

      await viewModel.start(payload);

      expect(viewModel.ideaDropped, isTrue);
      viewModel.dispose();
    });

    test(
      'a few failed checks in a row are tolerated, but a lost connection ends with a clear message',
      () async {
        final flaky = FakeStoryApi()
          ..jobScript.addAll([
            unreachable,
            unreachable,
            job(StoryJobStatus.done, withStory: true),
          ]);
        final tolerant = viewModelFor(flaky);
        await tolerant.start(payload);
        expect(
          tolerant.stage,
          LoadingStage.done,
          reason: 'two blips did not end the job',
        );
        tolerant.dispose();

        final dead = FakeStoryApi()..jobScript.add(unreachable);
        final viewModel = viewModelFor(dead, maxPollFailures: 3);
        await viewModel.start(payload);
        expect(viewModel.stage, LoadingStage.failed);
        expect(
          viewModel.failureMessage,
          LoadingViewModel.connectionLostMessage,
        );
        expect(dead.jobCalls.length, 3);
        viewModel.dispose();
      },
    );

    test('leaving the screen stops the polling', () async {
      final api = FakeStoryApi()
        ..jobScript.add(job(StoryJobStatus.writingStory));
      final viewModel = viewModelFor(api);

      final running = viewModel.start(payload);
      await until(viewModel, () => api.jobCalls.length >= 2);
      viewModel.dispose();
      final callsAtLeave = api.jobCalls.length;

      await Future<void>.delayed(const Duration(milliseconds: 40));
      expect(api.jobCalls.length, callsAtLeave);
      expect(
        viewModel.isWorking,
        isTrue,
        reason: 'the job itself keeps going on the backend',
      );
      running.ignore();
    });

    test('trying again after a failure starts clean', () async {
      final api = FakeStoryApi()
        ..jobScript.addAll([
          job(StoryJobStatus.failed, errorCode: 'ai_failed'),
          job(StoryJobStatus.done, withStory: true),
        ]);
      final viewModel = viewModelFor(api);

      await viewModel.start(payload);
      expect(viewModel.stage, LoadingStage.failed);

      await viewModel.start(payload);
      expect(viewModel.stage, LoadingStage.done);
      expect(viewModel.failureMessage, isNull);
      expect(api.startedJobs.length, 2);
      viewModel.dispose();
    });
  });

  group('Loading screen', () {
    Future<void> open(
      WidgetTester tester,
      FakeStoryApi api, {
      VoidCallback? onCreated,
    }) async {
      await tester.pumpWidget(
        Provider.value(
          value: fakeStories(api),
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoadingScreenView(
                        payload: payload,
                        onCreated: onCreated,
                      ),
                    ),
                  ),
                  child: const Text('go'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    phoneTest('shows the real step instead of an invented percentage', (
      tester,
    ) async {
      final api = FakeStoryApi()
        ..jobScript.add(job(StoryJobStatus.writingStory));
      await open(tester, api);

      expect(find.text('Step 1 of 2'), findsOneWidget);
      expect(find.textContaining('%'), findsNothing);
      expect(find.text('This can take up to a minute'), findsOneWidget);

      api.jobScript
        ..clear()
        ..add(job(StoryJobStatus.creatingVoice, withStory: true));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(find.text('Step 2 of 2'), findsOneWidget);
    });

    phoneTest(
      'when the story is ready it opens the result, and tells if the idea was not used',
      (tester) async {
        // Header gambar hasil (voice_image_header.dart) meluap pada font uji Ahem yang lebih lebar dari Quicksand.
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          if (details.exceptionAsString().contains('overflowed')) return;
          originalOnError?.call(details);
        };
        addTearDown(() => FlutterError.onError = originalOnError);

        final api = FakeStoryApi()
          ..jobScript.add(
            job(StoryJobStatus.done, withStory: true, ideaDropped: true),
          );
        var created = 0;
        await open(tester, api, onCreated: () => created++);
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.text('Re-Generate'), findsOneWidget);
        expect(find.text('Story 5'), findsOneWidget);
        expect(find.text('Aira flew to the moon.'), findsOneWidget);
        expect(find.text(LoadingViewModel.ideaDroppedNotice), findsOneWidget);
        expect(created, 1);

        await tester.pump(const Duration(seconds: 5));
      },
    );

    phoneTest(
      'a failure shows red text with Try again and Back, and Try again really retries',
      (tester) async {
        final api = FakeStoryApi()
          ..jobScript.addAll([
            job(StoryJobStatus.failed, errorCode: 'ai_unavailable'),
            job(StoryJobStatus.writingStory),
          ]);
        await open(tester, api);

        final message = find.textContaining("The story service isn't running");
        expect(message, findsOneWidget);
        expect(tester.widget<Text>(message).style?.color, Colors.red);
        expect(find.text('Try again'), findsOneWidget);
        expect(find.text('Back'), findsOneWidget);
        expect(find.byType(SnackBar), findsNothing);

        await tester.tap(find.byKey(const Key('failure-primary')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(api.startedJobs.length, 2);
        expect(find.text('Step 1 of 2'), findsOneWidget);
      },
    );

    phoneTest('Back from a failure returns to the previous screen', (
      tester,
    ) async {
      final api = FakeStoryApi()
        ..jobScript.add(job(StoryJobStatus.failed, errorCode: 'ai_failed'));
      await open(tester, api);

      await tester.tap(find.byKey(const Key('failure-secondary')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('go'), findsOneWidget);
    });

    phoneTest(
      'a saved story whose voice failed offers to open it instead of retrying',
      (tester) async {
        final api = FakeStoryApi()
          ..jobScript.add(
            job(
              StoryJobStatus.failed,
              withStory: true,
              errorCode: 'voice_failed',
            ),
          );
        await open(tester, api);

        expect(find.textContaining('Your story was saved'), findsOneWidget);
        expect(find.text('Open story'), findsOneWidget);
        expect(find.text('Try again'), findsNothing);
      },
    );

    phoneTest(
      'leaving while it works says it continues, and stops asking the server',
      (tester) async {
        final api = FakeStoryApi()
          ..jobScript.add(job(StoryJobStatus.writingStory));
        await open(tester, api);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.textContaining("We'll keep working on it"), findsOneWidget);
        final callsAtLeave = api.jobCalls.length;
        await tester.pump(const Duration(seconds: 10));
        expect(api.jobCalls.length, callsAtLeave);
      },
    );
  });

  group('Create form', () {
    setUp(() => SharedPreferences.setMockInitialValues({'active_child_id': 7}));

    CreateStoryViewModel filled({bool voice = true}) => CreateStoryViewModel()
      ..setCategory('Adventure')
      ..setCharacterName('Aira')
      ..setStoryLength('5 Minutes')
      ..setVoiceTone(voice ? 'Warm' : '');

    test('lists exactly what is still missing, voice included', () {
      expect(CreateStoryViewModel().missingFields(), [
        'a category',
        'a story length',
        'a voice',
      ]);
      expect(filled(voice: false).missingFields(), ['a voice']);
      expect(filled().missingFields(), isEmpty);
    });

    testWidgets(
      'a missing voice is explained inline in the view model and clears once chosen',
      (tester) async {
        await tester.pumpWidget(const SizedBox());
        final context = tester.element(find.byType(SizedBox));
        final viewModel = filled(voice: false);

        await viewModel.generateStory(context);

        expect(viewModel.errorMessage, 'Please choose a voice.');
        viewModel.setVoiceTone('Brave');
        expect(viewModel.errorMessage, isNull);
      },
    );

    testWidgets(
      'the form offers every voice, and the hint says Indonesian is fine',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 4000);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);
        final originalOnError = FlutterError.onError;
        FlutterError.onError = (details) {
          if (details.exceptionAsString().contains('overflowed')) return;
          originalOnError?.call(details);
        };
        addTearDown(() => FlutterError.onError = originalOnError);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider(create: (_) => CreateStoryViewModel()),
              ChangeNotifierProvider(create: (_) => NavbarViewModel()),
            ],
            child: const MaterialApp(home: Scaffold(body: CreateStoryView())),
          ),
        );
        await tester.pump();

        expect(find.text('Voice'), findsOneWidget);
        for (final voice in StoryDefaults.voices) {
          expect(find.text(voice), findsWidgets, reason: voice);
        }
        for (final onlyAVoice in [
          'Gentle',
          'Character',
          'Friendly',
          'Neutral',
        ]) {
          expect(find.text(onlyAVoice), findsOneWidget, reason: onlyAVoice);
        }
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is TextField &&
                w.decoration?.hintText?.contains('Indonesian') == true,
          ),
          findsOneWidget,
        );
      },
    );
  });
}
