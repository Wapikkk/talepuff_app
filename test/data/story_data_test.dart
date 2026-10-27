import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:talepuff_app/core/relative_time.dart';
import 'package:talepuff_app/l10n/app_localizations.dart';
import 'package:talepuff_app/data/models/account_result.dart';
import 'package:talepuff_app/data/models/app_message.dart';
import 'package:talepuff_app/data/models/story.dart';
import 'package:talepuff_app/data/models/story_job.dart';
import 'package:talepuff_app/data/repositories/story_repository.dart';
import 'package:talepuff_app/data/services/story_service.dart';

import '../support/fakes.dart';

Map<String, Object?> storyJson({int id = 5, Map<String, Object?> extra = const {}}) => {
      'id': id,
      'child_id': 7,
      'title': 'Moon Rocket',
      'theme': 'Adventure',
      'mood': 'Calm, Brave',
      'language': 'Basic English',
      'length_minutes': 5,
      'audio_url': '',
      'voice_tone': '',
      'is_favorite': true,
      'play_count': 2,
      'created_at': '2026-10-20T10:00:00Z',
      ...extra,
    };

void main() {
  group('StorySummary.fromJson', () {
    test('reads every field', () {
      final story = StorySummary.fromJson(storyJson());

      expect(story.id, 5);
      expect(story.title, 'Moon Rocket');
      expect(story.theme, 'Adventure');
      expect(story.lengthMinutes, 5);
      expect(story.isFavorite, isTrue);
      expect(story.playCount, 2);
      expect(story.createdAt.toUtc(), DateTime.utc(2026, 10, 20, 10));
      expect(story.moods, ['Calm', 'Brave']);
      expect(story.hasAudio, isFalse);
    });

    test('missing optional fields get safe defaults', () {
      final story = StorySummary.fromJson({'id': 1});

      expect(story.title, '');
      expect(story.isFavorite, isFalse);
      expect(story.lengthMinutes, 0);
      expect(story.moods, isEmpty);
    });

    test('a story without a valid id is rejected instead of silently becoming id 0', () {
      for (final bad in [<String, dynamic>{}, {'id': 0}, {'id': 'abc'}, {'ID': 5}]) {
        expect(() => StorySummary.fromJson(bad), throwsFormatException, reason: '$bad');
      }
    });

    test('StoryDetail adds the text and keeps everything else on copyWith', () {
      final detail = StoryDetail.fromJson(storyJson(extra: {'content': 'Once upon a time', 'description': 'idea'}));
      expect(detail.content, 'Once upon a time');
      expect(detail.description, 'idea');

      final changed = detail.copyWith(isFavorite: false);
      expect(changed.isFavorite, isFalse);
      expect(changed.content, 'Once upon a time');
    });
  });

  group('RelativeTime', () {
    final now = DateTime(2026, 10, 20, 12, 0);
    final en = lookupAppLocalizations(const Locale('en'));

    setUpAll(() => initializeDateFormatting('id'));

    test('wording by age', () {
      expect(RelativeTime.format(en, now.subtract(const Duration(seconds: 30)), now: now), 'Just now');
      expect(RelativeTime.format(en, now.subtract(const Duration(minutes: 7)), now: now), '7 min ago');
      expect(RelativeTime.format(en, now.subtract(const Duration(hours: 3)), now: now), '3 h ago');
      expect(RelativeTime.format(en, now.subtract(const Duration(days: 2)), now: now), '2 d ago');
      expect(RelativeTime.format(en, DateTime(2026, 3, 5), now: now), '5 Mar');
      expect(RelativeTime.format(en, DateTime(2025, 12, 31), now: now), '31 Dec 2025');
    });

    test('a time slightly in the future (clock skew) is "Just now"', () {
      expect(RelativeTime.format(en, now.add(const Duration(minutes: 2)), now: now), 'Just now');
    });

    test('Indonesian wording and month names', () {
      final id = lookupAppLocalizations(const Locale('id'));
      expect(RelativeTime.format(id, now.subtract(const Duration(seconds: 30)), now: now), 'Baru saja');
      expect(RelativeTime.format(id, now.subtract(const Duration(minutes: 7)), now: now), '7 menit lalu');
      expect(RelativeTime.format(id, DateTime(2026, 10, 5), now: now.add(const Duration(days: 30))), '5 Okt');
    });
  });

  group('StoryService', () {
    StoryService serviceWith(MockClientHandler handler, {Duration timeout = const Duration(seconds: 2)}) =>
        StoryService(client: MockClient(handler), baseUrl: 'http://backend/api', timeout: timeout);

    test('list sends the child, tab, query and paging as query parameters', () async {
      late Uri seen;
      final service = serviceWith((request) async {
        seen = request.url;
        return http.Response(jsonEncode({'stories': [storyJson()], 'has_more': true}), 200);
      });

      final page = await service.list(childId: 7, tab: StoryTab.favorites, query: 'moon & stars', offset: 30);

      expect(seen.path, '/api/stories');
      expect(seen.queryParameters, {'child_id': '7', 'tab': 'favorites', 'q': 'moon & stars', 'limit': '30', 'offset': '30'});
      expect(page.stories.single.title, 'Moon Rocket');
      expect(page.hasMore, isTrue);
    });

    test('an empty query is not sent', () async {
      late Uri seen;
      final service = serviceWith((request) async {
        seen = request.url;
        return http.Response('{"stories":[],"has_more":false}', 200);
      });

      await service.list(childId: 7, tab: StoryTab.recent);

      expect(seen.queryParameters.containsKey('q'), isFalse);
    });

    test('get reads the story from the "data" wrapper', () async {
      late Uri seen;
      final service = serviceWith((request) async {
        seen = request.url;
        return http.Response(jsonEncode({'data': storyJson(extra: {'content': 'Text'})}), 200);
      });

      final story = await service.get(5);

      expect(seen.path, '/api/stories/5');
      expect(story.content, 'Text');
    });

    test('setFavorite PUTs the wanted value', () async {
      late http.Request seen;
      final service = serviceWith((request) async {
        seen = request;
        return http.Response('{"is_favorite":true}', 200);
      });

      await service.setFavorite(5, true);

      expect(seen.method, 'PUT');
      expect(seen.url.path, '/api/stories/5/favorite');
      expect(jsonDecode(seen.body), {'favorite': true});
    });

    test('error statuses carry the code, and a plain-text 404 marks the route as missing', () async {
      final notFound = serviceWith((_) async => http.Response('{"error":"Story not found"}', 404));
      await expectLater(
        notFound.get(5),
        throwsA(isA<StoryApiException>()
            .having((e) => e.statusCode, 'statusCode', 404)
            .having((e) => e.endpointMissing, 'endpointMissing', isFalse)),
      );

      final missing = serviceWith((_) async => http.Response('404 page not found', 404));
      await expectLater(missing.get(5), throwsA(isA<StoryApiException>().having((e) => e.endpointMissing, 'endpointMissing', isTrue)));
    });

    test('a refused connection, a timeout and a malformed answer all fail cleanly', () async {
      final refused = serviceWith((_) async => throw const SocketException('refused'));
      await expectLater(refused.list(childId: 7, tab: StoryTab.recent), throwsA(isA<StoryApiException>()));

      final slow = serviceWith(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          return http.Response('{}', 200);
        },
        timeout: const Duration(milliseconds: 30),
      );
      await expectLater(slow.list(childId: 7, tab: StoryTab.recent), throwsA(isA<StoryApiException>()));

      for (final body in ['not json', '{"stories":"nope"}', '{"stories":[{"title":"no id"}]}']) {
        final bad = serviceWith((_) async => http.Response(body, 200));
        await expectLater(bad.list(childId: 7, tab: StoryTab.recent), throwsA(isA<StoryApiException>()), reason: body);
      }
    });
  });

  group('StoryRepository', () {
    test('list returns the stories and the "has more" flag', () async {
      final api = FakeStoryApi()..onList = (_) async => StoryPage([makeStory(1), makeStory(2)], hasMore: true);

      final result = await fakeStories(api).list(childId: 7, tab: StoryTab.recent);

      expect(result, isA<StoryListLoaded>());
      expect((result as StoryListLoaded).stories.map((s) => s.id), [1, 2]);
      expect(result.hasMore, isTrue);
    });

    test('failures become readable messages', () async {
      final expectations = {
        400: AppMessage.requestNotUnderstood,
        401: AppMessage.reloginRequired,
        403: AppMessage.reloginRequired,
        404: AppMessage.storyNotFound,
        500: AppMessage.serverUnreachable,
      };
      for (final entry in expectations.entries) {
        final api = FakeStoryApi()..listError = StoryApiException('x', statusCode: entry.key);
        final result = await fakeStories(api).list(childId: 7, tab: StoryTab.recent) as StoryListFailed;
        expect(result.message, entry.value, reason: '${entry.key}');
      }
    });

    test('a backend that was not restarted is explained', () async {
      final api = FakeStoryApi()..listError = const StoryApiException('x', statusCode: 404, endpointMissing: true);
      final result = await fakeStories(api).list(childId: 7, tab: StoryTab.recent) as StoryListFailed;
      expect(result.message, AppMessage.backendOutdated);
    });

    test('an unreadable answer is not reported as a network problem', () async {
      final api = FakeStoryApi()..listError = const StoryApiException('Unexpected response from the server');
      final result = await fakeStories(api).list(childId: 7, tab: StoryTab.recent) as StoryListFailed;
      expect(result.message, AppMessage.unreadableResponse);
    });

    test('get and setFavorite report success and failure', () async {
      final api = FakeStoryApi();
      final repository = fakeStories(api);

      expect(await repository.get(5), isA<StoryDetailLoaded>());
      expect(await repository.setFavorite(5, true), isA<AccountSuccess>());
      expect(api.favoriteCalls, ['5:true']);

      api.detailError = const StoryApiException('x', statusCode: 404);
      api.favoriteError = const StoryApiException('x', statusCode: 500);
      expect(await repository.get(5), isA<StoryDetailFailed>());
      expect(await repository.setFavorite(5, false), isA<AccountFailure>());
    });
  });

  group('story jobs', () {
    StoryService serviceWith(MockClientHandler handler) =>
        StoryService(client: MockClient(handler), baseUrl: 'http://backend/api');

    test('startJob posts the form and returns the job id from a 202', () async {
      late http.Request seen;
      final service = serviceWith((request) async {
        seen = request;
        return http.Response(jsonEncode({'job_id': 42, 'status': 'queued'}), 202);
      });

      final id = await service.startJob({'child_id': 7, 'voice_tone': 'Warm'});

      expect(id, 42);
      expect(seen.method, 'POST');
      expect(seen.url.path, '/api/story/generate');
      expect(jsonDecode(seen.body), {'child_id': 7, 'voice_tone': 'Warm'});
    });

    test('a 409 means a story is already being made, so it resumes that job instead of failing', () async {
      final service = serviceWith((_) async => http.Response(jsonEncode({'error': 'busy', 'job_id': 9}), 409));

      expect(await service.startJob({'child_id': 7}), 9);
    });

    test('other start failures keep their status code', () async {
      final service = serviceWith((_) async => http.Response('{"error":"bad"}', 400));

      await expectLater(service.startJob({}), throwsA(isA<StoryApiException>().having((e) => e.statusCode, 'status', 400)));
    });

    test('getJob reads the stage, the story, the error code and the idea flag', () async {
      late Uri seen;
      final service = serviceWith((request) async {
        seen = request.url;
        return http.Response(
          jsonEncode({
            'id': 9,
            'status': 'failed',
            'error_code': 'voice_failed',
            'idea_dropped': true,
            'story': {...storyJson(), 'content': 'Once upon a time.'},
          }),
          200,
        );
      });

      final job = await service.getJob(9);

      expect(seen.path, '/api/story/jobs/9');
      expect(job.status, StoryJobStatus.failed);
      expect(job.errorCode, 'voice_failed');
      expect(job.ideaDropped, isTrue);
      expect(job.story?.content, 'Once upon a time.');
    });

    test('every backend status is understood, and an unknown one is reported instead of guessed', () async {
      for (final entry in {
        'queued': StoryJobStatus.queued,
        'writing_story': StoryJobStatus.writingStory,
        'creating_voice': StoryJobStatus.creatingVoice,
        'done': StoryJobStatus.done,
        'failed': StoryJobStatus.failed,
      }.entries) {
        final service = serviceWith((_) async => http.Response(jsonEncode({'id': 1, 'status': entry.key}), 200));
        expect((await service.getJob(1)).status, entry.value, reason: entry.key);
      }

      final service = serviceWith((_) async => http.Response(jsonEncode({'id': 1, 'status': 'teleporting'}), 200));
      await expectLater(service.getJob(1), throwsA(isA<StoryApiException>()));
    });

    test('a backend without the job routes is reported as outdated', () async {
      final service = serviceWith((_) async => http.Response('404 page not found', 404));

      final result = await StoryRepository(api: service).startJob({'child_id': 7});

      expect(result, isA<JobStartFailed>());
      expect((result as JobStartFailed).message, AppMessage.backendOutdated);
    });
  });
}
