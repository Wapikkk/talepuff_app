import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:talepuff_app/data/models/child_profile.dart';
import 'package:talepuff_app/data/services/auth_service.dart';

AuthService serviceWith(MockClientHandler handler, {Duration timeout = const Duration(seconds: 2)}) =>
    AuthService(client: MockClient(handler), baseUrl: 'http://backend/api', timeout: timeout);

const draft = ChildDraft(name: 'Aira', age: 3, gender: 'Girl', interests: ['Space']);

void main() {
  group('fetchProfile', () {
    test('200 with a Go-style body is a found profile', () async {
      final service = serviceWith((_) async => http.Response(
            jsonEncode({'ID': 5, 'name': 'Aira', 'age': 3, 'interests': ['Space']}),
            200,
          ));

      final result = await service.fetchProfile('uid-1');

      expect(result, isA<ProfileFound>());
      expect((result as ProfileFound).profile.id, 5);
    });

    test('404 means the profile does not exist yet', () async {
      final service = serviceWith((_) async => http.Response('{"error":"not found"}', 404));
      expect(await service.fetchProfile('uid-1'), isA<ProfileNotFound>());
    });

    test('401 and 403 mean the server rejected the session, not that it is unreachable', () async {
      for (final status in [401, 403]) {
        final service = serviceWith((_) async => http.Response('{"error":"Invalid or expired token"}', status));
        expect(await service.fetchProfile('uid-1'), isA<ProfileRejected>(), reason: '$status');
      }
    });

    test('a 500 is "unreachable", never "not found"', () async {
      final service = serviceWith((_) async => http.Response('boom', 500));
      expect(await service.fetchProfile('uid-1'), isA<ProfileUnreachable>());
    });

    test('a refused connection is unreachable', () async {
      final service = serviceWith((_) async => throw const SocketException('refused'));
      expect(await service.fetchProfile('uid-1'), isA<ProfileUnreachable>());
    });

    test('a slow server times out as unreachable', () async {
      final service = serviceWith(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          return http.Response('{}', 200);
        },
        timeout: const Duration(milliseconds: 30),
      );
      expect(await service.fetchProfile('uid-1'), isA<ProfileUnreachable>());
    });

    test('malformed or unexpected bodies are unreachable instead of crashing', () async {
      for (final body in ['not json', '[1,2,3]', '{"name":"no id"}']) {
        final service = serviceWith((_) async => http.Response(body, 200));
        expect(await service.fetchProfile('uid-1'), isA<ProfileUnreachable>(), reason: body);
      }
    });

    test('the uid is URL-encoded', () async {
      Uri? seen;
      final service = serviceWith((request) async {
        seen = request.url;
        return http.Response('', 404);
      });
      await service.fetchProfile('a/b c');
      expect(seen!.toString(), 'http://backend/api/child/a%2Fb%20c');
    });
  });

  group('register', () {
    test('sends every field the backend expects', () async {
      late Map<String, dynamic> body;
      late http.BaseRequest request;
      final service = serviceWith((r) async {
        request = r;
        body = jsonDecode(r.body) as Map<String, dynamic>;
        return http.Response('{"message":"ok"}', 200);
      });

      await service.register(firebaseUid: 'uid-1', email: 'p@x.com', child: draft);

      expect(request.method, 'POST');
      expect(request.url.toString(), 'http://backend/api/register');
      expect(body, {
        'firebase_uid': 'uid-1',
        'email': 'p@x.com',
        'child_name': 'Aira',
        'age': 3,
        'gender': 'Girl',
        'interests': ['Space'],
      });
    });

    test('a non-200 answer throws with the status code', () async {
      final service = serviceWith((_) async => http.Response('bad', 500));
      await expectLater(
        service.register(firebaseUid: 'u', email: 'e', child: draft),
        throwsA(isA<ProfileApiException>().having((e) => e.statusCode, 'statusCode', 500)),
      );
    });

    test('a refused connection throws ProfileApiException', () async {
      final service = serviceWith((_) async => throw const SocketException('refused'));
      await expectLater(
        service.register(firebaseUid: 'u', email: 'e', child: draft),
        throwsA(isA<ProfileApiException>()),
      );
    });

    test('a timeout throws ProfileApiException', () async {
      final service = serviceWith(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          return http.Response('{}', 200);
        },
        timeout: const Duration(milliseconds: 20),
      );
      await expectLater(
        service.register(firebaseUid: 'u', email: 'e', child: draft),
        throwsA(isA<ProfileApiException>()),
      );
    });
  });

  group('updateChildName', () {
    test('sends a PUT with the name and treats 200 as success', () async {
      late http.Request seen;
      final service = serviceWith((request) async {
        seen = request;
        return http.Response('{"message":"ok"}', 200);
      });

      await service.updateChildName(childId: 7, name: 'Aira');

      expect(seen.method, 'PUT');
      expect(seen.url.toString(), 'http://backend/api/child/update-name/7');
      expect(jsonDecode(seen.body), {'name': 'Aira'});
    });

    test('a non-200 answer throws with the status code', () async {
      final service = serviceWith((_) async => http.Response('boom', 500));
      await expectLater(
        service.updateChildName(childId: 7, name: 'Aira'),
        throwsA(isA<ProfileApiException>().having((e) => e.statusCode, 'statusCode', 500)),
      );
    });

    test('a refused connection throws ProfileApiException', () async {
      final service = serviceWith((_) async => throw const SocketException('refused'));
      await expectLater(
        service.updateChildName(childId: 7, name: 'Aira'),
        throwsA(isA<ProfileApiException>()),
      );
    });
  });

}
