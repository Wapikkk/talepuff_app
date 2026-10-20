import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:talepuff_app/data/models/account_result.dart';
import 'package:talepuff_app/data/models/story.dart';
import 'package:talepuff_app/data/services/story_service.dart';
import 'package:talepuff_app/ui/view_models/story/story_detail_view_model.dart';
import 'package:talepuff_app/ui/view_models/story/story_filter_view_model.dart';

import '../support/fakes.dart';

StoryFilterViewModel make(FakeStoryApi api, {String? childId = '7', Duration delay = const Duration(milliseconds: 20)}) {
  return StoryFilterViewModel(repository: fakeStories(api), childId: () => childId, searchDelay: delay);
}

Future<void> pause([int ms = 80]) => Future<void>.delayed(Duration(milliseconds: ms));

void main() {
  group('StoryFilterViewModel loading', () {
    test('load asks for the recent tab of the active child and exposes the stories', () async {
      final api = FakeStoryApi()..onList = (_) async => StoryPage([makeStory(2), makeStory(1)], hasMore: false);
      final viewModel = make(api);

      await viewModel.load();

      expect(api.listCalls.single.toString(), 'recent||0');
      expect(api.listCalls.single.childId, 7);
      expect(viewModel.stories.map((s) => s.id), [2, 1]);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('without a loaded child there is a message and no request', () async {
      final api = FakeStoryApi();
      final viewModel = make(api, childId: null);

      await viewModel.load();

      expect(viewModel.errorMessage, contains('not been loaded'));
      expect(api.listCalls, isEmpty);
      expect(viewModel.isLoading, isFalse);
    });

    test('a failure sets the message, and a retry recovers', () async {
      final api = FakeStoryApi()..listError = const StoryApiException('down');
      final viewModel = make(api);

      await viewModel.load();
      expect(viewModel.errorMessage, isNotNull);
      expect(viewModel.stories, isEmpty);

      api
        ..listError = null
        ..onList = (_) async => StoryPage([makeStory(1)], hasMore: false);
      await viewModel.load();

      expect(viewModel.errorMessage, isNull);
      expect(viewModel.stories, hasLength(1));
    });

    test('a failed refresh keeps the stories already on screen', () async {
      final api = FakeStoryApi()..onList = (_) async => StoryPage([makeStory(1)], hasMore: false);
      final viewModel = make(api);
      await viewModel.load();

      api.listError = const StoryApiException('down');
      await viewModel.load();

      expect(viewModel.stories, hasLength(1));
      expect(viewModel.errorMessage, isNotNull);
    });
  });

  group('tabs', () {
    test('switching tab clears the old stories at once and loads the new tab', () async {
      final api = FakeStoryApi()
        ..onList = (call) async => StoryPage(
              call.tab == StoryTab.favorites ? [makeStory(9, favorite: true)] : [makeStory(1), makeStory(2)],
              hasMore: false,
            );
      final viewModel = make(api);
      await viewModel.load();

      final switching = viewModel.setTab(StoryTab.favorites);
      expect(viewModel.stories, isEmpty, reason: 'no stories from the previous tab while loading');
      await switching;

      expect(viewModel.tab, StoryTab.favorites);
      expect(viewModel.stories.map((s) => s.id), [9]);
      expect(api.listCalls.last.toString(), 'favorites||0');
    });

    test('choosing the current tab again does nothing', () async {
      final api = FakeStoryApi();
      final viewModel = make(api);
      await viewModel.load();

      await viewModel.setTab(StoryTab.recent);

      expect(api.listCalls, hasLength(1));
    });

    test('a slow answer for the old tab can never overwrite the new tab', () async {
      final slowRecent = Completer<StoryPage>();
      final api = FakeStoryApi()
        ..onList = (call) => call.tab == StoryTab.recent
            ? slowRecent.future
            : Future.value(StoryPage([makeStory(9, title: 'Favorite one')], hasMore: false));
      final viewModel = make(api);

      final first = viewModel.load(); // tab Recent, jawabannya ditahan
      await viewModel.setTab(StoryTab.favorites); // pengguna pindah tab, jawaban Favorites cepat

      slowRecent.complete(StoryPage([makeStory(1, title: 'Late recent')], hasMore: false));
      await first;

      expect(viewModel.stories.map((s) => s.title), ['Favorite one'], reason: 'the late answer was dropped');
      expect(viewModel.isLoading, isFalse);
    });
  });

  group('search', () {
    test('waits until the user stops typing, then sends one request for the final text', () async {
      final api = FakeStoryApi();
      final viewModel = make(api);
      await viewModel.load();
      api.listCalls.clear();

      viewModel.search('m');
      viewModel.search('mo');
      viewModel.search('moon');
      expect(api.listCalls, isEmpty, reason: 'nothing is sent while typing');

      await pause();

      expect(api.listCalls.map((c) => c.toString()), ['recent|moon|0']);
    });

    test('closing the search clears the keyword and shows the full list again', () async {
      final api = FakeStoryApi();
      final viewModel = make(api);
      viewModel.toggleSearch(true);
      viewModel.search('moon');
      await pause();
      api.listCalls.clear();

      viewModel.toggleSearch(false);
      await pause(10);

      expect(viewModel.query, '');
      expect(viewModel.isSearching, isFalse);
      expect(api.listCalls.map((c) => c.toString()), ['recent||0']);
    });

    test('closing the search without a keyword makes no request', () async {
      final api = FakeStoryApi();
      final viewModel = make(api);
      viewModel.toggleSearch(true);
      viewModel.toggleSearch(false);
      await pause();
      expect(api.listCalls, isEmpty);
    });

    test('whitespace-only text is treated as no keyword', () async {
      final api = FakeStoryApi();
      final viewModel = make(api);
      viewModel.search('   ');
      await pause();
      expect(api.listCalls.single.query, '');
    });
  });

  group('pagination', () {
    test('loadMore appends the next page using the number of stories already loaded as the offset', () async {
      final api = FakeStoryApi()
        ..onList = (call) async => call.offset == 0
            ? StoryPage([makeStory(1), makeStory(2)], hasMore: true)
            : StoryPage([makeStory(3)], hasMore: false);
      final viewModel = make(api);
      await viewModel.load();

      await viewModel.loadMore();

      expect(viewModel.stories.map((s) => s.id), [1, 2, 3]);
      expect(viewModel.hasMore, isFalse);
      expect(api.listCalls.last.offset, 2);
    });

    test('loadMore does nothing when there is no next page or a load is running', () async {
      final api = FakeStoryApi()..onList = (_) async => StoryPage([makeStory(1)], hasMore: false);
      final viewModel = make(api);
      await viewModel.load();
      await viewModel.loadMore();
      expect(api.listCalls, hasLength(1));

      final gate = Completer<StoryPage>();
      api.onList = (_) => gate.future;
      final loading = viewModel.load();
      await viewModel.loadMore();
      expect(api.listCalls, hasLength(2), reason: 'only the running load');
      gate.complete(const StoryPage([], hasMore: true));
      await loading;
    });

    test('a next page that arrives after a tab change is dropped', () async {
      final slowPage = Completer<StoryPage>();
      final api = FakeStoryApi()
        ..onList = (call) {
          if (call.offset > 0) return slowPage.future;
          return Future.value(StoryPage(
            call.tab == StoryTab.recent ? [makeStory(1), makeStory(2)] : [makeStory(9)],
            hasMore: call.tab == StoryTab.recent,
          ));
        };
      final viewModel = make(api);
      await viewModel.load();

      final more = viewModel.loadMore();
      await viewModel.setTab(StoryTab.favorites);
      slowPage.complete(StoryPage([makeStory(3)], hasMore: false));
      await more;

      expect(viewModel.stories.map((s) => s.id), [9]);
    });
  });

  group('favorites', () {
    test('the heart changes at once, and the server is told', () async {
      final api = FakeStoryApi()..onList = (_) async => StoryPage([makeStory(1), makeStory(2)], hasMore: false);
      final viewModel = make(api);
      await viewModel.load();

      final pending = viewModel.toggleFavorite(viewModel.stories[1]);
      expect(viewModel.stories[1].isFavorite, isTrue, reason: 'optimistic');
      final result = await pending;

      expect(result, isA<AccountSuccess>());
      expect(api.favoriteCalls, ['2:true']);
      expect(viewModel.stories[1].isFavorite, isTrue);
      expect(viewModel.stories[0].isFavorite, isFalse);
    });

    test('a server failure puts the heart back and reports why', () async {
      final api = FakeStoryApi();
      api.onList = (_) async => StoryPage([makeStory(1, favorite: true)], hasMore: false);
      api.favoriteError = const StoryApiException('down', statusCode: 500);
      final viewModel = make(api);
      await viewModel.load();

      final result = await viewModel.toggleFavorite(viewModel.stories.single);

      expect(result, isA<AccountFailure>());
      expect(viewModel.stories.single.isFavorite, isTrue, reason: 'rolled back');
    });

    test('on the Favorites tab, un-favoriting removes the story, and a failure brings it back in place', () async {
      final api = FakeStoryApi()
        ..onList = (_) async => StoryPage([makeStory(1, favorite: true), makeStory(2, favorite: true), makeStory(3, favorite: true)], hasMore: false);
      final viewModel = make(api);
      await viewModel.setTab(StoryTab.favorites);
      final middle = viewModel.stories[1];

      final removed = viewModel.toggleFavorite(middle);
      expect(viewModel.stories.map((s) => s.id), [1, 3]);
      await removed;

      api.favoriteError = const StoryApiException('down', statusCode: 500);
      final failing = viewModel.toggleFavorite(viewModel.stories[0]);
      expect(viewModel.stories.map((s) => s.id), [3]);
      await failing;

      expect(viewModel.stories.map((s) => s.id), [1, 3], reason: 'story 1 is back at its old position');
    });

    test('a story that is not in the list is ignored', () async {
      final api = FakeStoryApi();
      final viewModel = make(api);
      expect(await viewModel.toggleFavorite(makeStory(99)), isNull);
      expect(api.favoriteCalls, isEmpty);
    });
  });

  test('disposing while a request is running does not crash', () async {
    final gate = Completer<StoryPage>();
    final api = FakeStoryApi()..onList = (_) => gate.future;
    final viewModel = make(api);

    final loading = viewModel.load();
    viewModel.dispose();
    gate.complete(StoryPage([makeStory(1)], hasMore: false));

    await loading; // tidak boleh melempar "notifyListeners after dispose"
  });

  group('StoryDetailViewModel', () {
    StoryDetailViewModel makeDetailVm(FakeStoryApi api) => StoryDetailViewModel(repository: fakeStories(api));

    test('loads the story', () async {
      final api = FakeStoryApi()..detail = makeDetail(5);
      final viewModel = makeDetailVm(api);

      await viewModel.load(5);

      expect(viewModel.story?.id, 5);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('a failure leaves a message and no story', () async {
      final api = FakeStoryApi()..detailError = const StoryApiException('x', statusCode: 404);
      final viewModel = makeDetailVm(api);

      await viewModel.load(5);

      expect(viewModel.story, isNull);
      expect(viewModel.errorMessage, contains("couldn't find that story"));
    });

    test('favorite changes at once, is remembered for the list, and rolls back on failure', () async {
      final api = FakeStoryApi()..detail = makeDetail(5);
      final viewModel = makeDetailVm(api);
      await viewModel.load(5);

      final ok = await viewModel.toggleFavorite();
      expect(ok, isA<AccountSuccess>());
      expect(viewModel.story!.isFavorite, isTrue);
      expect(viewModel.favoriteChanged, isTrue);

      api.favoriteError = const StoryApiException('down', statusCode: 500);
      final failed = await viewModel.toggleFavorite();
      expect(failed, isA<AccountFailure>());
      expect(viewModel.story!.isFavorite, isTrue, reason: 'rolled back to the saved value');
    });

    test('a second tap while saving is ignored', () async {
      final api = FakeStoryApi()
        ..detail = makeDetail(5)
        ..favoriteGate = Completer<void>();
      final viewModel = makeDetailVm(api);
      await viewModel.load(5);

      final first = viewModel.toggleFavorite();
      expect(await viewModel.toggleFavorite(), isNull);

      api.favoriteGate!.complete();
      await first;
      expect(api.favoriteCalls, ['5:true']);
    });
  });
}
