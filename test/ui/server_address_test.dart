import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talepuff_app/core/server_address.dart';
import 'package:talepuff_app/data/models/app_message.dart';
import 'package:talepuff_app/data/models/story.dart';
import 'package:talepuff_app/data/services/authenticated_client.dart';
import 'package:talepuff_app/data/services/server_check_service.dart';
import 'package:talepuff_app/data/services/story_service.dart';
import 'package:talepuff_app/ui/view_models/settings/server_address_view_model.dart';
import 'package:talepuff_app/ui/views/settings/server_address_view.dart';
import '../support/l10n.dart';

class FakeChecker implements ServerChecker {
  ServerCheckResult result = const ServerReachable();
  Completer<void>? gate;
  final checked = <String>[];

  @override
  Future<ServerCheckResult> check(String baseUrl) async {
    checked.add(baseUrl);
    await gate?.future;
    return result;
  }
}

AppMessage message(ServerAddressResult result) =>
    (result as InvalidServerAddress).message;

String url(ServerAddressResult result) => (result as ValidServerAddress).url;

void main() {
  setUp(() {
    dotenv.loadFromString(envString: 'API_BASE_URL=http://10.0.0.9:8080');
    SharedPreferences.setMockInitialValues({});
    ServerAddress.forgetForTest();
  });

  group('ServerAddress.parse', () {
    test(
      'accepts the addresses of a home or hotspot network and fills in the scheme and port',
      () {
        expect(
          url(ServerAddress.parse('192.168.1.5')),
          'http://192.168.1.5:8080',
        );
        expect(
          url(ServerAddress.parse('192.168.1.5:9000')),
          'http://192.168.1.5:9000',
        );
        expect(
          url(ServerAddress.parse('  172.20.10.2:8080  ')),
          'http://172.20.10.2:8080',
        );
        expect(
          url(ServerAddress.parse('http://10.0.2.2:8080/')),
          'http://10.0.2.2:8080',
        );
        expect(
          url(ServerAddress.parse('172.31.255.1')),
          'http://172.31.255.1:8080',
        );
        expect(
          url(ServerAddress.parse('my-laptop.local')),
          'http://my-laptop.local:8080',
        );
        expect(
          url(ServerAddress.parse('localhost:8080')),
          'http://localhost:8080',
        );
      },
    );

    test(
      'refuses internet addresses, so the login token can never be sent to the outside',
      () {
        for (final bad in [
          '8.8.8.8',
          'example.com',
          'https://api.example.com',
          '172.32.0.1',
          '172.15.0.1',
          '192.169.1.1',
          '11.0.0.1',
          '192.168.1.5.evil.com',
          '192.168.1',
        ]) {
          expect(
            ServerAddress.parse(bad),
            isA<InvalidServerAddress>(),
            reason: bad,
          );
        }
        expect(message(ServerAddress.parse('8.8.8.8')), AppMessage.addressNotLocal);
      },
    );

    test('refuses things that are not just an address and a port', () {
      for (final bad in [
        '192.168.1.5:8080/api',
        '192.168.1.5?x=1',
        'user@192.168.1.5',
        'ftp://192.168.1.5',
      ]) {
        expect(
          ServerAddress.parse(bad),
          isA<InvalidServerAddress>(),
          reason: bad,
        );
      }
      expect(ServerAddress.parse(''), isA<InvalidServerAddress>());
      expect(ServerAddress.parse('   '), isA<InvalidServerAddress>());
      expect(ServerAddress.parse('http://'), isA<InvalidServerAddress>());
    });
  });

  group('ServerAddress storage', () {
    test('uses the built-in address until one is saved', () {
      expect(ServerAddress.baseUrl, 'http://10.0.0.9:8080');
      expect(ServerAddress.isCustom, isFalse);
    });

    test(
      'a saved address wins, survives a restart, and can be reset',
      () async {
        await ServerAddress.save('http://192.168.1.5:8080');
        expect(ServerAddress.baseUrl, 'http://192.168.1.5:8080');
        expect(ServerAddress.isCustom, isTrue);

        ServerAddress.forgetForTest();
        expect(
          ServerAddress.baseUrl,
          'http://10.0.0.9:8080',
          reason: 'memory is empty, like right after a restart',
        );
        await ServerAddress.load();
        expect(ServerAddress.baseUrl, 'http://192.168.1.5:8080');

        await ServerAddress.reset();
        expect(ServerAddress.baseUrl, 'http://10.0.0.9:8080');
        ServerAddress.forgetForTest();
        await ServerAddress.load();
        expect(ServerAddress.isCustom, isFalse);
      },
    );

    test(
      'a stored value that is not a valid local address is ignored',
      () async {
        SharedPreferences.setMockInitialValues({
          'server_base_url': 'http://evil.example.com:8080',
        });

        await ServerAddress.load();

        expect(ServerAddress.baseUrl, 'http://10.0.0.9:8080');
      },
    );

    test(
      'after saving, the services really talk to the new host, and only that host gets the token',
      () async {
        final seen = <Uri>[];
        final headers = <String?>[];
        final inner = MockClient((request) async {
          seen.add(request.url);
          headers.add(request.headers['Authorization']);
          return http.Response(
            jsonEncode({'stories': <Object>[], 'has_more': false}),
            200,
          );
        });
        final client = AuthenticatedClient(
          idToken: () async => 'token-123',
          baseUrl: () => ServerAddress.baseUrl,
          inner: inner,
        );
        final service = StoryService(client: client);

        await service.list(childId: 1, tab: StoryTab.recent);
        await ServerAddress.save('http://192.168.1.77:8080');
        await service.list(childId: 1, tab: StoryTab.recent);

        expect(seen[0].host, '10.0.0.9');
        expect(seen[1].host, '192.168.1.77');
        expect(headers, ['Bearer token-123', 'Bearer token-123']);

        await client.get(Uri.parse('http://10.0.0.9:8080/api/stories'));
        expect(
          headers.last,
          isNull,
          reason: 'the old address no longer receives the token',
        );
      },
    );
  });

  group('ServerCheckService', () {
    ServerCheckService serviceWith(MockClientHandler handler) =>
        ServerCheckService(
          client: MockClient(handler),
          timeout: const Duration(milliseconds: 100),
        );

    test('recognises the TalePuff backend on /api/health', () async {
      late Uri seen;
      final service = serviceWith((request) async {
        seen = request.url;
        return http.Response(
          jsonEncode({'status': 'ok', 'service': 'talepuff'}),
          200,
        );
      });

      expect(
        await service.check('http://192.168.1.5:8080'),
        isA<ServerReachable>(),
      );
      expect(seen.toString(), 'http://192.168.1.5:8080/api/health');
    });

    test(
      'a server that answers but is something else, or an old TalePuff, is told apart from no answer',
      () async {
        expect(
          await serviceWith(
            (_) async => http.Response('404 page not found', 404),
          ).check('http://x:1'),
          isA<ServerNotTalePuff>(),
        );
        expect(
          await serviceWith(
            (_) async => http.Response('<html>router</html>', 200),
          ).check('http://x:1'),
          isA<ServerNotTalePuff>(),
        );
        expect(
          await serviceWith(
            (_) async => http.Response('{"service":"other"}', 200),
          ).check('http://x:1'),
          isA<ServerNotTalePuff>(),
        );
      },
    );

    test('no answer at all is reported as unreachable', () async {
      expect(
        await serviceWith(
          (_) async => throw const SocketException('down'),
        ).check('http://x:1'),
        isA<ServerUnreachable>(),
      );
      expect(
        await serviceWith(
          (_) async => throw http.ClientException('down'),
        ).check('http://x:1'),
        isA<ServerUnreachable>(),
      );
      expect(
        await serviceWith(
          (_) => Completer<http.Response>().future,
        ).check('http://x:1'),
        isA<ServerUnreachable>(),
        reason: 'a silent host times out',
      );
    });
  });

  group('ServerAddressViewModel', () {
    test(
      'an invalid address is explained without touching the network',
      () async {
        final checker = FakeChecker();
        final viewModel = ServerAddressViewModel(checker: checker);

        expect(await viewModel.check('8.8.8.8'), isNull);

        expect(viewModel.error, AppMessage.addressNotLocal);
        expect(checker.checked, isEmpty);
        viewModel.dispose();
      },
    );

    test(
      'a reachable server returns the normalised address and clears the error',
      () async {
        final checker = FakeChecker();
        final viewModel = ServerAddressViewModel(checker: checker);

        expect(await viewModel.check('192.168.1.5'), 'http://192.168.1.5:8080');

        expect(checker.checked, ['http://192.168.1.5:8080']);
        expect(viewModel.error, isNull);
        viewModel.dispose();
      },
    );

    test('each kind of failure has its own plain message', () async {
      final checker = FakeChecker()..result = const ServerUnreachable();
      final viewModel = ServerAddressViewModel(checker: checker);

      expect(await viewModel.check('192.168.1.5'), isNull);
      expect(viewModel.error, AppMessage.addressUnreachable);

      checker.result = const ServerNotTalePuff();
      expect(await viewModel.check('192.168.1.5'), isNull);
      expect(viewModel.error, AppMessage.addressNotTalepuff);
      viewModel.dispose();
    });

    test('a second test while one is running is ignored', () async {
      final checker = FakeChecker()..gate = Completer<void>();
      final viewModel = ServerAddressViewModel(checker: checker);

      final first = viewModel.check('192.168.1.5');
      expect(viewModel.isChecking, isTrue);
      expect(await viewModel.check('192.168.1.5'), isNull);
      checker.gate!.complete();
      await first;

      expect(checker.checked.length, 1);
      expect(viewModel.isChecking, isFalse);
      viewModel.dispose();
    });

    test('save keeps only valid addresses, and useDefault goes back', () async {
      final viewModel = ServerAddressViewModel(checker: FakeChecker());

      expect(await viewModel.save('example.com'), ServerSaveOutcome.invalid);
      expect(ServerAddress.isCustom, isFalse);

      expect(await viewModel.save('192.168.1.5'), ServerSaveOutcome.saved);
      expect(ServerAddress.baseUrl, 'http://192.168.1.5:8080');
      expect(viewModel.error, isNull);

      await viewModel.useDefault();
      expect(ServerAddress.baseUrl, 'http://10.0.0.9:8080');
      viewModel.dispose();
    });
  });

  group('Server address screen', () {
    late FakeChecker checker;

    Future<void> open(WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      // Judul header (update_header_settings.dart) meluap pada font uji Ahem yang lebih lebar dari Quicksand.
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);
      checker = FakeChecker();

      await tester.pumpWidget(
        Provider<ServerChecker>.value(
          value: checker,
          child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: testLocale, 
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ServerAddressView(),
                    ),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
    }

    testWidgets('starts with the current address, without http://', (
      tester,
    ) async {
      await open(tester);

      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        '10.0.0.9:8080',
      );
      expect(
        find.byKey(const Key('use-default')),
        findsNothing,
        reason: 'nothing custom to undo yet',
      );
    });

    testWidgets(
      'a bad address is explained in red under the buttons, with no network call',
      (tester) async {
        await open(tester);

        await tester.enterText(find.byType(TextField), '8.8.8.8');
        await tester.tap(find.byKey(const Key('test-connection')));
        await tester.pump();

        final error = find.textContaining('not an internet address');
        expect(error, findsOneWidget);
        expect(tester.widget<Text>(error).style?.color, Colors.redAccent);
        expect(checker.checked, isEmpty);
        expect(find.byType(SnackBar), findsNothing);
      },
    );

    testWidgets(
      'a good test shows the green banner and does not save by itself',
      (tester) async {
        await open(tester);

        await tester.enterText(find.byType(TextField), '192.168.1.5');
        await tester.tap(find.byKey(const Key('test-connection')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('Connected to the server'), findsOneWidget);
        expect(ServerAddress.isCustom, isFalse);

        await tester.pump(const Duration(seconds: 4));
        await tester.pump(const Duration(seconds: 1));
      },
    );

    testWidgets('a failed test says why in red', (tester) async {
      await open(tester);
      checker.result = const ServerUnreachable();

      await tester.enterText(find.byType(TextField), '192.168.1.5');
      await tester.tap(find.byKey(const Key('test-connection')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining("Can’t reach that address"), findsOneWidget);
      expect(find.text('Connected to the server'), findsNothing);
    });

    testWidgets('Save stores the address, confirms in green and goes back', (
      tester,
    ) async {
      await open(tester);

      await tester.enterText(find.byType(TextField), '192.168.1.5');
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(ServerAddress.baseUrl, 'http://192.168.1.5:8080');
      expect(find.text('Server address saved'), findsOneWidget);
      expect(
        find.text('open'),
        findsOneWidget,
        reason: 'back on the previous screen',
      );

      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets(
      'a custom address can be dropped in favour of the built-in one',
      (tester) async {
        await ServerAddress.save('http://192.168.1.5:8080');
        await open(tester);
        expect(
          tester.widget<TextField>(find.byType(TextField)).controller?.text,
          '192.168.1.5:8080',
        );

        await tester.tap(find.byKey(const Key('use-default')));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(ServerAddress.isCustom, isFalse);
        expect(find.text('Back to the built-in address'), findsOneWidget);

        await tester.pump(const Duration(seconds: 4));
        await tester.pump(const Duration(seconds: 1));
      },
    );
  });
}
