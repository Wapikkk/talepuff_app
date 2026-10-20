import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:talepuff_app/core/validators.dart';
import 'package:talepuff_app/data/models/account_result.dart';
import 'package:talepuff_app/data/repositories/feedback_repository.dart';
import 'package:talepuff_app/data/services/feedback_service.dart';

import '../support/fakes.dart';

String failureOf(AccountResult result) => (result as AccountFailure).message;

void main() {
  group('FeedbackValidators.message (same rule as the server)', () {
    test('accepts 5 to 1000 characters, counting characters not bytes', () {
      for (final ok in ['hello', '  hello  ', 'a' * 1000, 'é' * 1000, 'line one\nline two']) {
        expect(FeedbackValidators.message(ok), isNull, reason: ok.length > 20 ? '${ok.length} chars' : ok);
      }
    });

    test('rejects empty, too short and too long', () {
      for (final bad in ['', '    ', 'hi', 'a' * 1001]) {
        expect(FeedbackValidators.message(bad), isNotNull, reason: '${bad.length} chars');
      }
    });
  });

  group('FeedbackService', () {
    FeedbackService serviceWith(MockClientHandler handler, {Duration timeout = const Duration(seconds: 2)}) =>
        FeedbackService(client: MockClient(handler), baseUrl: 'http://backend/api', timeout: timeout);

    test('POSTs the category, message and version', () async {
      late http.Request seen;
      final service = serviceWith((request) async {
        seen = request;
        return http.Response('{"message":"ok"}', 201);
      });

      await service.send(category: 'bug', message: 'It crashed', appVersion: '1.0.0+1');

      expect(seen.method, 'POST');
      expect(seen.url.toString(), 'http://backend/api/feedback');
      expect(jsonDecode(seen.body), {'category': 'bug', 'message': 'It crashed', 'app_version': '1.0.0+1'});
    });

    test('a non-success status throws with the status code', () async {
      final service = serviceWith((_) async => http.Response('too many', 429));
      await expectLater(
        service.send(category: 'bug', message: 'hello there', appVersion: ''),
        throwsA(isA<FeedbackApiException>().having((e) => e.statusCode, 'statusCode', 429)),
      );
    });

    test("Gin's plain-text 404 means the route is missing; a JSON 404 means the account is", () async {
      final missing = serviceWith((_) async => http.Response('404 page not found', 404));
      await expectLater(
        missing.send(category: 'bug', message: 'hello there', appVersion: ''),
        throwsA(isA<FeedbackApiException>().having((e) => e.endpointMissing, 'endpointMissing', isTrue)),
      );

      final noUser = serviceWith((_) async => http.Response('{"error":"User not found"}', 404));
      await expectLater(
        noUser.send(category: 'bug', message: 'hello there', appVersion: ''),
        throwsA(isA<FeedbackApiException>().having((e) => e.endpointMissing, 'endpointMissing', isFalse)),
      );
    });

    test('a refused connection and a timeout both throw FeedbackApiException', () async {
      final refused = serviceWith((_) async => throw const SocketException('refused'));
      await expectLater(refused.send(category: 'bug', message: 'hello there', appVersion: ''), throwsA(isA<FeedbackApiException>()));

      final slow = serviceWith(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          return http.Response('{}', 201);
        },
        timeout: const Duration(milliseconds: 30),
      );
      await expectLater(slow.send(category: 'bug', message: 'hello there', appVersion: ''), throwsA(isA<FeedbackApiException>()));
    });
  });

  group('FeedbackRepository', () {
    FeedbackRepository make(FakeFeedbackApi api, {FakeAppInfo? info}) =>
        FeedbackRepository(api: api, appInfo: info ?? FakeAppInfo());

    test('sends the trimmed message with the app version', () async {
      final api = FakeFeedbackApi();
      final result = await make(api).send(category: 'idea', message: '  More stories please  ');

      expect(result, isA<AccountSuccess>());
      expect(api.sent, [
        {'category': 'idea', 'message': 'More stories please', 'version': '1.0.0+1'},
      ]);
    });

    test('invalid input never reaches the server', () async {
      final api = FakeFeedbackApi();
      final repository = make(api);

      expect(await repository.send(category: 'idea', message: 'hi'), isA<AccountFailure>());
      expect(await repository.send(category: 'idea', message: ''), isA<AccountFailure>());
      expect(failureOf(await repository.send(category: 'complaint', message: 'A fine message')), contains('category'));
      expect(api.sent, isEmpty);
    });

    test('a version that cannot be read does not block the feedback', () async {
      final api = FakeFeedbackApi();
      final result = await make(api, info: FakeAppInfo(fails: true)).send(category: 'bug', message: 'Something broke');

      expect(result, isA<AccountSuccess>());
      expect(api.sent.single['version'], '');
    });

    test('server answers map to specific messages', () async {
      final expectations = {
        400: "didn't accept",
        401: 'login again',
        403: 'login again',
        404: "couldn't find your account",
        429: 'a lot of feedback',
        500: "Can't reach the server",
      };
      for (final entry in expectations.entries) {
        final api = FakeFeedbackApi()..error = FeedbackApiException('x', statusCode: entry.key);
        final result = await make(api).send(category: 'bug', message: 'Something broke');
        expect(failureOf(result), contains(entry.value), reason: '${entry.key}');
      }
    });

    test('a missing route (backend not restarted) is explained, not reported as a missing account', () async {
      final api = FakeFeedbackApi()..error = const FeedbackApiException('x', statusCode: 404, endpointMissing: true);
      final message = failureOf(await make(api).send(category: 'bug', message: 'Something broke'));
      expect(message, contains('restart the backend'));
      expect(message, isNot(contains('find your account')));
    });

    test('a connection failure is reported as such', () async {
      final api = FakeFeedbackApi()..error = const FeedbackApiException('down');
      expect(failureOf(await make(api).send(category: 'bug', message: 'Something broke')), contains("Can't reach the server"));
    });
  });
}
