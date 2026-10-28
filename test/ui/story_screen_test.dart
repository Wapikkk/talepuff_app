import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/data/models/child_profile.dart';
import 'package:talepuff_app/data/models/story.dart';
import 'package:talepuff_app/data/services/story_service.dart';
import 'package:talepuff_app/data/services/totem_service.dart';
import 'package:talepuff_app/ui/view_models/navbar_view_model.dart';
import 'package:talepuff_app/ui/view_models/parents/child_info_view_model.dart';
import 'package:talepuff_app/ui/view_models/parents/parent_view_model.dart';
import 'package:talepuff_app/ui/views/story/story_detail_view.dart';
import 'package:talepuff_app/ui/views/story/story_view.dart';

import '../support/fakes.dart';
import '../support/l10n.dart';

/// Layar ukuran ponsel (1080x2400 px pada 3x = 360x800 dp), bukan 800x600 bawaan.
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

/// Animasi baru mulai pada frame berikutnya, jadi dua pump. (pumpAndSettle tidak dipakai: latar bintang
/// dan awan beranimasi terus.)
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

class Harness {
  Harness(this.api, {FakeTotemApi? totem}) : totemApi = totem ?? FakeTotemApi() {
    parent = ParentViewModel(photos: fakePhotos())
      ..setInitiateData('7', null, 'Aira');
    childInfo = ChildInfoViewModel(repository: AuthFixture().repository)
      ..applyProfile(const ChildProfile(id: 7, name: 'Aira'));
    navbar = NavbarViewModel();
  }

  final FakeStoryApi api;
  final FakeTotemApi totemApi;
  late final ParentViewModel parent;
  late final ChildInfoViewModel childInfo;
  late final NavbarViewModel navbar;

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider.value(value: fakeStories(api)),
          ChangeNotifierProvider.value(value: parent),
          ChangeNotifierProvider.value(value: childInfo),
          ChangeNotifierProvider.value(value: navbar),
          ChangeNotifierProvider(create: (_) => fakeTotemViewModel(totemApi)),
        ],
        child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: testLocale, 
          home: const StoryView(),
          routes: {
            '/story_detail': (_) => const StoryDetailView(),
            '/totem': (_) => const Text('TOTEM', textDirection: TextDirection.ltr),
          },
        ),
      ),
    );
    await settle(tester);
  }
}

FakeStoryApi apiWith(
  List<StorySummary> recent, {
  List<StorySummary> favorites = const [],
  List<StorySummary> popular = const [],
}) {
  final api = FakeStoryApi();
  api.onList = (call) async {
    final stories = switch (call.tab) {
      StoryTab.recent => recent,
      StoryTab.favorites => favorites,
      StoryTab.popular => popular,
    };
    final matching = call.query.isEmpty
        ? stories
        : stories
              .where(
                (s) => s.title.toLowerCase().contains(call.query.toLowerCase()),
              )
              .toList();
    return StoryPage(matching, hasMore: false);
  };
  return api;
}

void main() {
  group('Story screen', () {
    phoneTest(
      'shows the real stories (title, how long ago, length) and none of the old sample data',
      (tester) async {
        final api = apiWith([
          makeStory(
            2,
            title: 'The Moon Rocket',
            theme: 'Adventure',
            minutes: 5,
            age: const Duration(minutes: 7),
          ),
          makeStory(
            1,
            title: 'The Sleeping Cloud',
            theme: 'Daily',
            minutes: 3,
            age: const Duration(hours: 3),
          ),
        ]);
        await Harness(api).pump(tester);

        expect(find.text('The Moon Rocket'), findsOneWidget);
        expect(find.text('The Sleeping Cloud'), findsOneWidget);
        expect(find.text('7 min ago'), findsOneWidget);
        expect(find.text('3 h ago'), findsOneWidget);
        expect(find.text('5 min'), findsOneWidget);
        expect(find.text("Aira’s stories"), findsOneWidget);

        expect(
          find.text("Aira's Space Adventure"),
          findsNothing,
          reason: 'the sample player card is gone',
        );
        expect(
          find.text('7 min ago'),
          findsOneWidget,
          reason: 'times come from the data, not a constant',
        );
      },
    );

    phoneTest(
      'a story just created appears first, because the page loads fresh each time it opens',
      (tester) async {
        final api = apiWith([
          makeStory(5, title: 'Brand new', age: const Duration(seconds: 20)),
          makeStory(1),
        ]);
        await Harness(api).pump(tester);

        expect(find.text('Brand new'), findsOneWidget);
        expect(find.text('Just now'), findsOneWidget);
      },
    );

    phoneTest('empty states explain each tab', (tester) async {
      final harness = Harness(apiWith([]));
      await harness.pump(tester);

      expect(find.text('No story has been created.'), findsOneWidget);

      await tester.tap(find.byKey(const Key('tab-favorites')));
      await settle(tester);
      expect(find.textContaining('No favorite stories yet'), findsOneWidget);

      await tester.tap(find.byKey(const Key('tab-popular')));
      await settle(tester);
      expect(find.textContaining('play the most'), findsOneWidget);
    });

    phoneTest('the empty "Recent" state leads to the Create tab', (
      tester,
    ) async {
      final harness = Harness(apiWith([]));
      await harness.pump(tester);

      await tester.tap(find.text("Let’s create a story"));
      await tester.pump();

      expect(harness.navbar.currentIndex, 2);
    });

    phoneTest('each tab shows its own stories', (tester) async {
      final api = apiWith(
        [makeStory(1, title: 'Recent one')],
        favorites: [makeStory(2, title: 'Favorite one', favorite: true)],
        popular: [makeStory(3, title: 'Popular one', plays: 4)],
      );
      await Harness(api).pump(tester);
      expect(find.text('Recent one'), findsOneWidget);

      await tester.tap(find.byKey(const Key('tab-favorites')));
      await settle(tester);
      expect(find.text('Favorite one'), findsOneWidget);
      expect(find.text('Recent one'), findsNothing);

      await tester.tap(find.byKey(const Key('tab-popular')));
      await settle(tester);
      expect(find.text('Popular one'), findsOneWidget);
    });

    phoneTest('a failed load shows the reason and "Try again" recovers', (
      tester,
    ) async {
      final api = apiWith([makeStory(1, title: 'Recovered')]);
      api.listError = const StoryApiException('down', statusCode: 500);
      await Harness(api).pump(tester);

      expect(find.textContaining("Can't reach the server"), findsOneWidget);
      expect(find.text('Recovered'), findsNothing);

      api.listError = null;
      await tester.tap(find.text('Try again'));
      await settle(tester);

      expect(find.text('Recovered'), findsOneWidget);
      expect(find.textContaining("Can't reach the server"), findsNothing);
    });

    phoneTest(
      'searching: type, wait, and only the matches remain; closing the search restores the list',
      (tester) async {
        final api = apiWith([
          makeStory(1, title: 'The Moon Rocket'),
          makeStory(2, title: 'The Sleeping Cloud'),
        ]);
        await Harness(api).pump(tester);

        await tester.tap(find.byKey(const Key('open-search')));
        await tester.pump();
        await tester.enterText(find.byType(TextField), 'moon');
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();

        expect(find.text('The Moon Rocket'), findsOneWidget);
        expect(find.text('The Sleeping Cloud'), findsNothing);

        await tester.enterText(find.byType(TextField), 'zzz');
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();
        expect(find.text('No stories match "zzz".'), findsOneWidget);
      },
    );

    phoneTest(
      'tapping the heart fills it at once; a server failure puts it back with a red banner',
      (tester) async {
        final api = apiWith([makeStory(1, title: 'My story')]);
        api.favoriteError = const StoryApiException('down', statusCode: 500);
        await Harness(api).pump(tester);

        final heart = find.byKey(const Key('favorite-1'));
        expect(
          find.descendant(
            of: heart,
            matching: find.byIcon(Icons.favorite_border),
          ),
          findsOneWidget,
        );

        await tester.tap(heart);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(
          find.descendant(
            of: heart,
            matching: find.byIcon(Icons.favorite_border),
          ),
          findsOneWidget,
          reason: 'rolled back',
        );
        expect(find.textContaining("Can't reach the server"), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);

        await tester.pump(const Duration(seconds: 4));
        await tester.pump(const Duration(seconds: 1));
      },
    );

    phoneTest('a successful heart tap is saved and the heart stays filled', (
      tester,
    ) async {
      final api = apiWith([makeStory(1, title: 'My story')]);
      await Harness(api).pump(tester);

      await tester.tap(find.byKey(const Key('favorite-1')));
      await settle(tester);

      expect(api.favoriteCalls, ['1:true']);
      expect(
        find.descendant(
          of: find.byKey(const Key('favorite-1')),
          matching: find.byIcon(Icons.favorite),
        ),
        findsOneWidget,
      );
    });

    phoneTest('the trash icon asks first, and Cancel keeps the story', (
      tester,
    ) async {
      final api = apiWith([makeStory(1, title: 'My story')]);
      await Harness(api).pump(tester);

      await tester.tap(find.byKey(const Key('delete-1')));
      await settle(tester);

      expect(find.text('Delete this story?'), findsOneWidget);
      expect(find.textContaining('"My story"'), findsOneWidget);

      await tester.tap(find.byKey(const Key('cancel-delete')));
      await settle(tester);

      expect(api.deleteCalls, isEmpty);
      expect(find.text('My story'), findsOneWidget);
    });

    phoneTest('confirming removes the card and shows the green banner', (
      tester,
    ) async {
      final api = apiWith([
        makeStory(1, title: 'My story'),
        makeStory(2, title: 'Another one'),
      ]);
      await Harness(api).pump(tester);

      await tester.tap(find.byKey(const Key('delete-1')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('confirm-delete')));
      await settle(tester);

      expect(api.deleteCalls, [1]);
      expect(find.text('My story'), findsNothing);
      expect(find.text('Another one'), findsOneWidget);
      expect(find.text('Story deleted.'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(seconds: 1));
    });

    phoneTest(
      'a failed delete keeps the story and says why in the red banner',
      (tester) async {
        final api = apiWith([makeStory(1, title: 'My story')]);
        api.deleteError = const StoryApiException('down', statusCode: 500);
        await Harness(api).pump(tester);

        await tester.tap(find.byKey(const Key('delete-1')));
        await settle(tester);
        await tester.tap(find.byKey(const Key('confirm-delete')));
        await settle(tester);

        expect(find.text('My story'), findsOneWidget);
        expect(find.textContaining("Can't reach the server"), findsOneWidget);
        expect(find.byIcon(Icons.error), findsOneWidget);

        await tester.pump(const Duration(seconds: 4));
        await tester.pump(const Duration(seconds: 1));
      },
    );

    phoneTest('while deleting, the card shows a spinner and taps are ignored', (
      tester,
    ) async {
      final api = apiWith([makeStory(1, title: 'My story')]);
      api.deleteGate = Completer<void>();
      await Harness(api).pump(tester);

      await tester.tap(find.byKey(const Key('delete-1')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('confirm-delete')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(
        find.descendant(
          of: find.byKey(const Key('delete-1')),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const Key('delete-1')));
      await tester.pump();
      expect(
        find.text('Delete this story?'),
        findsNothing,
        reason: 'no second dialog',
      );

      api.deleteGate!.complete();
      await settle(tester);
      expect(api.deleteCalls, [1]);

      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(seconds: 1));
    });

    phoneTest('a story that is already gone on the server is simply removed', (
      tester,
    ) async {
      final api = apiWith([makeStory(1, title: 'My story')]);
      api.deleteError = const StoryApiException('gone', statusCode: 404);
      await Harness(api).pump(tester);

      await tester.tap(find.byKey(const Key('delete-1')));
      await settle(tester);
      await tester.tap(find.byKey(const Key('confirm-delete')));
      await settle(tester);

      expect(find.text('My story'), findsNothing);

      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(seconds: 1));
    });
  });

  group('Story detail', () {
    phoneTest('opens from a card and shows the whole story in paragraphs', (
      tester,
    ) async {
      final api = apiWith([
        makeStory(1, title: 'The Moon Rocket', theme: 'Adventure'),
      ]);
      api.detail = makeDetail(
        1,
        content: 'Aira flies up.\n\nThe moon is bright.',
      );
      await Harness(api).pump(tester);

      await tester.tap(find.text('The Moon Rocket'));
      await settle(tester);

      expect(find.text('Aira flies up.'), findsOneWidget);
      expect(find.text('The moon is bright.'), findsOneWidget);
      expect(find.text('Calm'), findsOneWidget, reason: 'mood chips');
      expect(find.text('Brave'), findsOneWidget);
      expect(find.text('Play on totem'), findsOneWidget);
    });

    Future<Harness> openStory(WidgetTester tester, FakeTotemApi totem) async {
      final harness = Harness(apiWith([makeStory(1)]), totem: totem);
      await harness.pump(tester);
      await tester.tap(find.text('Story 1'));
      await settle(tester);
      return harness;
    }

    Future<void> dismissBanner(WidgetTester tester) async {
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(seconds: 1));
    }

    phoneTest('"Play on totem" without a linked totem asks to link one and opens the Totem screen', (tester) async {
      final totem = FakeTotemApi();
      await openStory(tester, totem);

      await tester.tap(find.byKey(const Key('play-on-totem')));
      await settle(tester);

      expect(find.text('TOTEM'), findsOneWidget);
      expect(totem.calls, isEmpty);
      await dismissBanner(tester);
    });

    phoneTest('"Play on totem" sends the story to the linked totem and shows the remote', (tester) async {
      final totem = FakeTotemApi()..current = pairedTotem();
      await openStory(tester, totem);
      expect(find.byKey(const Key('totem-controls')), findsNothing, reason: 'nothing is playing yet');

      await tester.tap(find.byKey(const Key('play-on-totem')));
      await settle(tester);

      expect(totem.calls, ['play:1']);
      expect(find.byKey(const Key('totem-controls')), findsOneWidget);
      expect(find.text('Playing  0:03 / 0:36'), findsOneWidget);
    });

    phoneTest('the remote pauses, resumes, stops and changes the volume', (tester) async {
      final totem = FakeTotemApi()..current = pairedTotem();
      await openStory(tester, totem);
      await tester.tap(find.byKey(const Key('play-on-totem')));
      await settle(tester);

      await tester.tap(find.byKey(const Key('totem-toggle')));
      await settle(tester);
      expect(find.textContaining('Paused'), findsOneWidget);

      await tester.tap(find.byKey(const Key('totem-toggle')));
      await settle(tester);
      expect(find.textContaining('Playing'), findsOneWidget);

      await tester.drag(find.byKey(const Key('totem-volume')), const Offset(-60, 0));
      await settle(tester);
      expect(totem.calls.last, startsWith('volume:'));

      await tester.tap(find.byKey(const Key('totem-stop')));
      await settle(tester);
      expect(totem.calls, containsAllInOrder(['play:1', 'pause', 'resume', 'stop']));
      expect(find.byKey(const Key('totem-controls')), findsNothing, reason: 'the totem stopped');
    });

    phoneTest('the remote is not shown when the totem plays another story', (tester) async {
      final totem = FakeTotemApi()..current = pairedTotem(state: 'playing', storyId: 99);
      await openStory(tester, totem);
      expect(find.byKey(const Key('totem-controls')), findsNothing);
    });

    phoneTest('an offline totem is explained instead of failing silently', (tester) async {
      final totem = FakeTotemApi()
        ..current = pairedTotem()
        ..error = const TotemApiException('x', statusCode: 409, code: 'totem_offline');
      await openStory(tester, totem);

      await tester.tap(find.byKey(const Key('play-on-totem')));
      await settle(tester);

      expect(find.text('Your totem is offline. Turn it on and try again.'), findsOneWidget);
      expect(find.byKey(const Key('totem-controls')), findsNothing);
      await dismissBanner(tester);
    });

    phoneTest(
      'changing the favorite there refreshes the list when coming back',
      (tester) async {
        final api = apiWith([makeStory(1)]);
        await Harness(api).pump(tester);
        final callsBefore = api.listCalls.length;

        await tester.tap(find.text('Story 1'));
        await settle(tester);
        await tester.tap(find.byKey(const Key('detail-favorite')));
        await settle(tester);
        expect(api.favoriteCalls, ['1:true']);

        await tester.tap(find.byIcon(Icons.arrow_back));
        await settle(tester);

        expect(
          find.byKey(const Key('detail-favorite')),
          findsNothing,
          reason: 'back on the list',
        );
        expect(
          api.listCalls.length,
          callsBefore + 1,
          reason: 'the list was reloaded',
        );
      },
    );

    phoneTest('going back without changing anything does not reload the list', (
      tester,
    ) async {
      final api = apiWith([makeStory(1)]);
      await Harness(api).pump(tester);
      final callsBefore = api.listCalls.length;

      await tester.tap(find.text('Story 1'));
      await settle(tester);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await settle(tester);

      expect(api.listCalls.length, callsBefore);
    });

    phoneTest('a story that cannot be loaded explains why', (tester) async {
      final api = apiWith([makeStory(1)]);
      api.detailError = const StoryApiException('x', statusCode: 404);
      await Harness(api).pump(tester);

      await tester.tap(find.text('Story 1'));
      await settle(tester);

      expect(find.textContaining("couldn’t find that story"), findsOneWidget);
    });
  });
}
