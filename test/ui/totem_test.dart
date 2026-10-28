import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/data/models/account_result.dart';
import 'package:talepuff_app/data/models/app_message.dart';
import 'package:talepuff_app/data/models/totem.dart';
import 'package:talepuff_app/data/repositories/totem_repository.dart';
import 'package:talepuff_app/data/services/totem_service.dart';
import 'package:talepuff_app/ui/view_models/totem/totem_view_model.dart';
import 'package:talepuff_app/ui/views/settings/totem_view.dart';

import '../support/fakes.dart';
import '../support/l10n.dart';

AppMessage failureOf(AccountResult result) => (result as AccountFailure).message;

void main() {
  group('TotemService', () {
    TotemService serviceWith(MockClientHandler handler) =>
        TotemService(client: MockClient(handler), baseUrl: 'http://backend/api', timeout: const Duration(seconds: 2));

    test('info reads the pairing and the live status', () async {
      final service = serviceWith((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), 'http://backend/api/totem');
        return http.Response(
          jsonEncode({
            'paired': true,
            'device_id': 'totem-001',
            'status': {'online': true, 'state': 'playing', 'story_id': 7, 'position': 12, 'duration': 36, 'volume': 40, 'reason': null},
          }),
          200,
        );
      });

      final info = await service.info();

      expect(info.paired, isTrue);
      expect(info.deviceId, 'totem-001');
      expect(info.status.isPlayingStory(7), isTrue);
      expect(info.status.position, 12);
    });

    test('an unpaired account has no status', () async {
      final info = await serviceWith((_) async => http.Response('{"paired":false}', 200)).info();
      expect(info.paired, isFalse);
      expect(info.status.online, isFalse);
    });

    test('commands are sent as JSON to the right route', () async {
      final seen = <String>[];
      final service = serviceWith((request) async {
        seen.add('${request.method} ${request.url.path} ${request.body}');
        return http.Response('{}', 200);
      });

      await service.pair('totem-001');
      await service.play(7, volume: 30);
      await service.command('volume', value: 20);
      await service.command('pause');
      await service.unpair();

      expect(seen, [
        'POST /api/totem/pair {"device_id":"totem-001"}',
        'POST /api/totem/play {"story_id":7,"volume":30}',
        'POST /api/totem/command {"action":"volume","value":20}',
        'POST /api/totem/command {"action":"pause"}',
        'DELETE /api/totem ',
      ]);
    });

    test('the error code from the backend is kept', () async {
      final service = serviceWith((_) async => http.Response('{"error":"x","code":"totem_offline"}', 409));
      await expectLater(
        service.command('pause'),
        throwsA(isA<TotemApiException>().having((e) => e.code, 'code', 'totem_offline').having((e) => e.statusCode, 'status', 409)),
      );
    });

    test('a refused connection and a timeout both throw TotemApiException', () async {
      await expectLater(serviceWith((_) async => throw const SocketException('refused')).info(), throwsA(isA<TotemApiException>()));
      final slow = TotemService(
        client: MockClient((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          return http.Response('{}', 200);
        }),
        baseUrl: 'http://backend/api',
        timeout: const Duration(milliseconds: 30),
      );
      await expectLater(slow.info(), throwsA(isA<TotemApiException>()));
    });
  });

  group('TotemRepository', () {
    test('pair normalises the id and never sends a malformed one', () async {
      final api = FakeTotemApi();
      final repository = TotemRepository(api: api);

      for (final bad in ['', 'ab', 'Totem 001', 'totem/001', 'totem-001/#', '-totem']) {
        expect(failureOf(await repository.pair(bad)), AppMessage.totemInvalidId, reason: bad);
      }
      expect(api.calls, isEmpty);

      final ok = await repository.pair('  TOTEM-001 ');
      expect(ok, isA<AccountSuccess>());
      expect((ok as AccountSuccess).value, 'totem-001');
      expect(api.calls, ['pair:totem-001']);
    });

    test('backend codes become message codes', () async {
      final expectations = {
        'invalid_device_id': AppMessage.totemInvalidId,
        'totem_not_visible': AppMessage.totemNotVisible,
        'totem_taken': AppMessage.totemTaken,
        'totem_not_paired': AppMessage.totemNotPaired,
        'totem_offline': AppMessage.totemOffline,
        'totem_unreachable': AppMessage.totemUnreachable,
        'totem_unavailable': AppMessage.totemUnavailable,
        'story_no_voice': AppMessage.storyNoVoice,
      };
      for (final entry in expectations.entries) {
        final api = FakeTotemApi()..error = TotemApiException('x', statusCode: 409, code: entry.key);
        expect(failureOf(await TotemRepository(api: api).play(1)), entry.value, reason: entry.key);
      }
    });

    test('without a code the status decides', () async {
      final expectations = {401: AppMessage.reloginRequired, 403: AppMessage.reloginRequired, 404: AppMessage.storyNotFound, 500: AppMessage.serverUnreachable};
      for (final entry in expectations.entries) {
        final api = FakeTotemApi()..error = TotemApiException('x', statusCode: entry.key);
        expect(failureOf(await TotemRepository(api: api).pause()), entry.value, reason: '${entry.key}');
      }
      final outdated = FakeTotemApi()..error = const TotemApiException('x', statusCode: 404, endpointMissing: true);
      expect(failureOf(await TotemRepository(api: outdated).pause()), AppMessage.backendOutdated);
    });

    test('volume is kept inside 0..100', () async {
      final api = FakeTotemApi()..current = pairedTotem();
      final repository = TotemRepository(api: api);
      await repository.setVolume(250);
      await repository.setVolume(-5);
      expect(api.calls, ['volume:100', 'volume:0']);
    });
  });

  group('TotemViewModel', () {
    test('refresh loads the totem; a failure keeps the last known state', () async {
      final api = FakeTotemApi()..current = pairedTotem();
      final vm = TotemViewModel(repository: TotemRepository(api: api));

      await vm.refresh();
      expect(vm.isPaired, isTrue);
      expect(vm.deviceId, 'totem-001');

      api.infoError = const TotemApiException('down');
      await vm.refresh();
      expect(vm.error, AppMessage.serverUnreachable);
      expect(vm.isPaired, isTrue, reason: 'the last known state stays');
      vm.dispose();
    });

    test('polling runs only while someone is watching', () async {
      var calls = 0;
      final counting = _CountingApi(FakeTotemApi()..current = pairedTotem(), () => calls++);
      final vm = TotemViewModel(repository: TotemRepository(api: counting), pollInterval: const Duration(milliseconds: 20));
      Future<void> wait() => Future<void>.delayed(const Duration(milliseconds: 120));

      vm.watch();
      vm.watch();
      await wait();
      expect(calls, greaterThan(2), reason: 'it polls while watched');

      vm.unwatch();
      var before = calls;
      await wait();
      expect(calls, greaterThan(before), reason: 'still watched by the second screen');

      vm.unwatch();
      await Future<void>.delayed(const Duration(milliseconds: 40));
      before = calls;
      await wait();
      expect(calls, before, reason: 'nobody is watching, so it stops');
      vm.dispose();
    });

    test('a second action while one is running is ignored', () async {
      final api = FakeTotemApi()..current = pairedTotem();
      final vm = TotemViewModel(repository: TotemRepository(api: api));

      final first = vm.pause();
      final second = await vm.pause();

      expect(second, isNull);
      await first;
      expect(api.calls, ['pause']);
      vm.dispose();
    });

    test('reset forgets the previous account\'s totem', () async {
      final api = FakeTotemApi()..current = pairedTotem();
      final vm = TotemViewModel(repository: TotemRepository(api: api));
      await vm.refresh();

      vm.reset();

      expect(vm.isLoaded, isFalse);
      expect(vm.isPaired, isFalse);
      vm.dispose();
    });
  });

  group('Totem screen', () {
    Widget app(FakeTotemApi api, {Locale locale = testLocale}) => ChangeNotifierProvider(
          create: (_) => fakeTotemViewModel(api),
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: locale,
            home: const TotemView(),
          ),
        );

    Future<void> settle(WidgetTester tester) async {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    testWidgets('links a totem by id and then shows it', (tester) async {
      final api = FakeTotemApi();
      await tester.pumpWidget(app(api));
      await settle(tester);

      await tester.enterText(find.byType(TextField), 'Totem-001');
      await tester.tap(find.text('Link totem'));
      await settle(tester);

      expect(api.calls, ['pair:totem-001']);
      expect(find.byKey(const Key('totem-device')), findsOneWidget);
      expect(find.text('Linked to totem-001'), findsOneWidget);
      expect(find.text('Idle'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('a rejected id shows the reason and stays on the form', (tester) async {
      final api = FakeTotemApi()..error = const TotemApiException('x', statusCode: 409, code: 'totem_taken');
      await tester.pumpWidget(app(api));
      await settle(tester);

      await tester.enterText(find.byType(TextField), 'totem-001');
      await tester.tap(find.text('Link totem'));
      await settle(tester);

      expect(find.text('This totem is already linked to another account.'), findsOneWidget);
      expect(find.text('Link totem'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('an offline totem is shown as offline, and it can be unlinked', (tester) async {
      final api = FakeTotemApi()..current = pairedTotem(online: false);
      await tester.pumpWidget(app(api));
      await settle(tester);

      expect(find.text('Offline'), findsOneWidget);

      await tester.tap(find.text('Unlink totem'));
      await settle(tester);

      expect(api.calls, ['unpair']);
      expect(find.text('Link totem'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('a server that cannot be reached is explained', (tester) async {
      final api = FakeTotemApi()..infoError = const TotemApiException('down');
      await tester.pumpWidget(app(api));
      await settle(tester);

      expect(find.byKey(const Key('totem-error')), findsOneWidget);
    });

    testWidgets('speaks Indonesian when the app does', (tester) async {
      final api = FakeTotemApi();
      await tester.pumpWidget(app(api, locale: const Locale('id')));
      await settle(tester);

      expect(find.text('Hubungkan totem'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'x');
      await tester.tap(find.text('Hubungkan totem'));
      await settle(tester);

      expect(find.textContaining('bukan ID totem yang valid'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });
  });
}

class _CountingApi implements TotemApi {
  _CountingApi(this._inner, this._onInfo);
  final TotemApi _inner;
  final void Function() _onInfo;

  @override
  Future<TotemInfo> info() {
    _onInfo();
    return _inner.info();
  }

  @override
  Future<void> pair(String deviceId) => _inner.pair(deviceId);
  @override
  Future<void> unpair() => _inner.unpair();
  @override
  Future<void> play(int storyId, {int? volume}) => _inner.play(storyId, volume: volume);
  @override
  Future<void> command(String action, {int? value}) => _inner.command(action, value: value);
}
