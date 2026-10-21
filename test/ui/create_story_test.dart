import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/core/story_defaults.dart';
import 'package:talepuff_app/ui/view_models/create_story/create_story_view_model.dart';
import 'package:talepuff_app/ui/view_models/navbar_view_model.dart';
import 'package:talepuff_app/ui/views/create_story/create_story_view.dart';

void main() {
  group('CreateStoryViewModel.buildPayload', () {
    CreateStoryViewModel filled() => CreateStoryViewModel()
      ..setCategory('Adventure')
      ..setCharacterName('  Aira  ')
      ..setStoryLength('5 Minutes')
      ..toggleMood('Calm')
      ..toggleMood('Brave')
      ..setVoiceTone('Warm')
      ..setDescription('  A trip to the moon  ');

    test(
      'always asks for Basic English, now that mixed English + Indonesian is gone',
      () {
        expect(filled().buildPayload(childId: 7)['language'], 'Basic English');
        expect(StoryDefaults.language, 'Basic English');
      },
    );

    test('carries the whole form, tidied up', () {
      expect(filled().buildPayload(childId: 7), {
        'child_id': 7,
        'character_name': 'Aira',
        'theme': 'Adventure',
        'mood': 'Calm, Brave',
        'length_minutes': 5,
        'language': 'Basic English',
        'description': 'A trip to the moon',
        'voice_tone': 'Warm',
      });
    });

    test(
      'an unreadable length falls back to 3 minutes, and no moods or description are fine',
      () {
        final payload =
            (CreateStoryViewModel()
                  ..setCategory('Daily')
                  ..setCharacterName('Aira')
                  ..setStoryLength('soon'))
                .buildPayload(childId: 1);

        expect(payload['length_minutes'], 3);
        expect(payload['mood'], '');
        expect(payload['description'], '');
      },
    );
  });

  test('reset empties the whole form and bumps the form version', () {
    final vm = CreateStoryViewModel()
      ..setCategory('Adventure')
      ..setCharacterName('Aira')
      ..setStoryLength('5 Minutes')
      ..toggleMood('Calm')
      ..setVoiceTone('Gentle')
      ..setDescription('moon');
    final before = vm.formVersion;

    vm.reset();

    expect(vm.selectedCategory, '');
    expect(vm.characterName, '');
    expect(vm.storyLength, '');
    expect(vm.selectedMoods, isEmpty);
    expect(vm.description, '');
    expect(vm.voiceTone, '');
    expect(vm.formVersion, before + 1);
  });

  testWidgets('the Create form no longer offers a language choice', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // Ubin kategori (category_selector.dart, kotak 70x90) meluap 10 px pada font uji yang lebih lebar
    // dari Quicksand. Itu bukan urusan tes ini, jadi hanya peringatan overflow yang diabaikan.
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

    expect(find.text('Language'), findsNothing);
    expect(find.text('Basic English'), findsNothing);
    expect(find.text('Mixed (EN + ID)'), findsNothing);
    expect(
      find.text('Mood'),
      findsOneWidget,
      reason: 'the rest of the form is still there',
    );
    expect(find.text('Describe Your Story'), findsOneWidget);
  });
}
