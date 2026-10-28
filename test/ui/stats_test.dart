import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/data/models/app_message.dart';
import 'package:talepuff_app/data/models/weekly_stats.dart';
import 'package:talepuff_app/data/repositories/stats_repository.dart';
import 'package:talepuff_app/data/services/stats_service.dart';
import 'package:talepuff_app/ui/view_models/parents/parent_view_model.dart';
import 'package:talepuff_app/ui/view_models/stats/stats_view_model.dart';
import 'package:talepuff_app/ui/widgets/parent/usage_statistic_card.dart';

import '../support/fakes.dart';
import '../support/l10n.dart';

void main() {
  group('WeeklyStats', () {
    test('reads the backend answer', () {
      final stats = WeeklyStats.fromJson({
        'days': [
          {'date': '2026-10-27', 'stories': 1, 'plays': 2, 'seconds': 90},
          {'date': '2026-10-28', 'stories': 0, 'plays': 1, 'seconds': 20},
        ],
      });
      expect(stats.days, hasLength(2));
      expect(stats.days.first.date, DateTime(2026, 10, 27));
      expect([stats.stories, stats.plays, stats.seconds], [1, 3, 110]);
      expect(stats.maxSeconds, 90);
      expect(stats.isEmpty, isFalse);
    });

    test('minutes never show 0 for something that was really heard', () {
      expect(DayStats(date: DateTime(2026), seconds: 0).minutes, 0);
      expect(DayStats(date: DateTime(2026), seconds: 10).minutes, 1);
      expect(DayStats(date: DateTime(2026), seconds: 150).minutes, 3);
      expect(weekOf(seconds: {1: 20, 5: 40}).minutes, 1);
      expect(weekOf(seconds: {1: 600, 5: 660}).minutes, 21);
    });

    test('a week with nothing is empty', () {
      expect(weekOf().isEmpty, isTrue);
      expect(weekOf(stories: {6: 1}).isEmpty, isFalse);
    });

    test('an answer without days is rejected', () {
      expect(() => WeeklyStats.fromJson({}), throwsFormatException);
    });
  });

  group('StatsService', () {
    StatsService serviceWith(MockClientHandler handler) =>
        StatsService(client: MockClient(handler), baseUrl: 'http://backend/api', timeout: const Duration(seconds: 2));

    test('asks for the child and parses the days', () async {
      late http.Request seen;
      final service = serviceWith((request) async {
        seen = request;
        return http.Response(jsonEncode({'days': [{'date': '2026-10-28', 'stories': 1, 'plays': 1, 'seconds': 60}]}), 200);
      });

      final stats = await service.weekly(7);

      expect(seen.url.toString(), 'http://backend/api/stats/weekly?child_id=7');
      expect(stats.plays, 1);
    });

    test('failures keep the status, and garbage is reported as unreadable', () async {
      await expectLater(
        serviceWith((_) async => http.Response('nope', 404)).weekly(7),
        throwsA(isA<StatsApiException>().having((e) => e.statusCode, 'status', 404).having((e) => e.endpointMissing, 'missing', isTrue)),
      );
      await expectLater(
        serviceWith((_) async => http.Response('not json', 200)).weekly(7),
        throwsA(isA<StatsApiException>().having((e) => e.message, 'message', 'Unexpected response from the server')),
      );
    });
  });

  group('StatsRepository', () {
    test('maps errors to message codes', () async {
      final expectations = {
        401: AppMessage.reloginRequired,
        404: AppMessage.childProfileNotFound,
        400: AppMessage.requestNotUnderstood,
        500: AppMessage.serverUnreachable,
      };
      for (final entry in expectations.entries) {
        final api = FakeStatsApi()..error = StatsApiException('x', statusCode: entry.key);
        final result = await StatsRepository(api: api).weekly(1);
        expect((result as StatsFailed).message, entry.value, reason: '${entry.key}');
      }
      final outdated = FakeStatsApi()..error = const StatsApiException('x', statusCode: 404, endpointMissing: true);
      expect(((await StatsRepository(api: outdated).weekly(1)) as StatsFailed).message, AppMessage.backendOutdated);
    });
  });

  group('StatsViewModel', () {
    test('loads for the child and clears the old child\'s numbers while the next one loads', () async {
      final api = FakeStatsApi()..result = weekOf(plays: {6: 2});
      final vm = StatsViewModel(repository: StatsRepository(api: api));

      await vm.load('7');
      expect(vm.stats?.plays, 2);

      final gate = Completer<void>();
      final slow = _GatedStatsApi(gate, weekOf());
      final other = StatsViewModel(repository: StatsRepository(api: slow));
      await other.load('7');
      final next = other.load('8');
      expect(other.stats, isNull, reason: 'numbers of child 7 are not shown for child 8');
      gate.complete();
      await next;
      expect(other.stats, isNotNull);
      vm.dispose();
      other.dispose();
    });

    test('an unknown child is reported and a failure keeps the error', () async {
      final api = FakeStatsApi();
      final vm = StatsViewModel(repository: StatsRepository(api: api));

      await vm.load(null);
      expect(vm.error, AppMessage.childDataNotLoaded);
      expect(api.calls, isEmpty);

      api.error = const StatsApiException('down');
      await vm.load('7');
      expect(vm.error, AppMessage.serverUnreachable);
      expect(vm.isLoading, isFalse);
      vm.dispose();
    });
  });

  group('Statistics card', () {
    Widget app(FakeStatsApi api, {Locale locale = testLocale}) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => fakeStatsViewModel(api)),
            ChangeNotifierProvider(create: (_) => ParentViewModel(photos: fakePhotos())..setInitiateData('7', null, 'Aira')),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,
            home: const Scaffold(body: SingleChildScrollView(child: Padding(padding: EdgeInsets.all(16), child: UsageStatisticCard()))),
          ),
        );

    Future<void> settle(WidgetTester tester) async {
      await tester.pump();
      await tester.pump();
    }

    testWidgets('shows the totals and one bar per day, tallest where most was heard', (tester) async {
      final api = FakeStatsApi()..result = weekOf(seconds: {3: 120, 6: 480}, plays: {3: 1, 6: 2}, stories: {6: 1});
      await tester.pumpWidget(app(api));
      await settle(tester);

      expect(api.calls, [7]);
      expect(find.text('Aira\u2019s listening week overview'), findsOneWidget);
      expect(find.text('1 Stories'), findsOneWidget);
      expect(find.text('3 Plays'), findsOneWidget);
      expect(find.text('10 Minutes'), findsOneWidget);
      expect(find.byKey(const Key('stats-empty')), findsNothing);

      final tallest = tester.getSize(find.byKey(const Key('stats-bar-28'))).height;
      final shorter = tester.getSize(find.byKey(const Key('stats-bar-25'))).height;
      final empty = tester.getSize(find.byKey(const Key('stats-bar-22'))).height;
      expect(tallest, 56);
      expect(shorter, closeTo(14, 0.01));
      expect(empty, 4, reason: 'an empty day is still a visible stub');
      expect(find.byWidgetPredicate((w) => w is Container && w.key.toString().contains('stats-bar')), findsNWidgets(7));
    });

    testWidgets('an empty week invites playing a story instead of showing a flat chart', (tester) async {
      await tester.pumpWidget(app(FakeStatsApi()));
      await settle(tester);

      expect(find.byKey(const Key('stats-empty')), findsOneWidget);
      expect(find.byWidgetPredicate((w) => w is Container && w.key.toString().contains('stats-bar')), findsNothing);
    });

    testWidgets('a failure is explained and Try again loads it', (tester) async {
      final api = FakeStatsApi()..error = const StatsApiException('down');
      await tester.pumpWidget(app(api));
      await settle(tester);
      expect(find.byKey(const Key('stats-error')), findsOneWidget);

      api
        ..error = null
        ..result = weekOf(plays: {6: 1}, seconds: {6: 60});
      await tester.tap(find.byKey(const Key('stats-retry')));
      await settle(tester);

      expect(find.byKey(const Key('stats-error')), findsNothing);
      expect(find.text('1 Plays'), findsOneWidget);
    });

    testWidgets('speaks Indonesian, including the weekday letters', (tester) async {
      final api = FakeStatsApi()..result = weekOf(plays: {6: 1}, seconds: {6: 60});
      await tester.pumpWidget(app(api, locale: const Locale('id')));
      await settle(tester);

      expect(find.text('Ringkasan mendengarkan Aira minggu ini'), findsOneWidget);
      expect(find.text('1 Diputar'), findsOneWidget);
      expect(find.text('1 Menit'), findsOneWidget);
    });
  });
}

class _GatedStatsApi implements StatsApi {
  _GatedStatsApi(this._gate, this._result);
  final Completer<void> _gate;
  final WeeklyStats _result;
  int _calls = 0;

  @override
  Future<WeeklyStats> weekly(int childId) async {
    if (++_calls > 1) await _gate.future;
    return _result;
  }
}
