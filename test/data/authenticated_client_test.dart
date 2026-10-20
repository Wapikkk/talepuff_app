import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:talepuff_app/data/services/authenticated_client.dart';

AuthenticatedClient clientWith(
  MockClientHandler handler, {
  Future<String?> Function()? idToken,
  String baseUrl = 'http://10.0.0.5:8080',
}) {
  return AuthenticatedClient(
    idToken: idToken ?? () async => 'tok-123',
    baseUrl: () => baseUrl,
    inner: MockClient(handler),
  );
}

void main() {
  test('adds the Firebase token to requests for the backend', () async {
    late http.BaseRequest seen;
    final client = clientWith((request) async {
      seen = request;
      return http.Response('{}', 200);
    });

    await client.get(Uri.parse('http://10.0.0.5:8080/api/child/uid-1'));

    expect(seen.headers['Authorization'], 'Bearer tok-123');
  });

  test('works for POST, PUT and multipart uploads too', () async {
    final seen = <String>[];
    final client = clientWith((request) async {
      seen.add('${request.method}:${request.headers['Authorization']}');
      return http.Response('{}', 200);
    });
    final url = Uri.parse('http://10.0.0.5:8080/api/x');

    await client.post(url, body: '{}');
    await client.put(url, body: '{}');
    final upload = http.MultipartRequest('POST', url)..files.add(http.MultipartFile.fromBytes('photo', [1, 2, 3], filename: 'a.jpg'));
    await client.send(upload);

    expect(seen, ['POST:Bearer tok-123', 'PUT:Bearer tok-123', 'POST:Bearer tok-123']);
  });

  test('asks for the token on every request, so a refreshed token is used', () async {
    var calls = 0;
    final seen = <String?>[];
    final client = clientWith(
      (request) async {
        seen.add(request.headers['Authorization']);
        return http.Response('{}', 200);
      },
      idToken: () async => 'token-${++calls}',
    );

    await client.get(Uri.parse('http://10.0.0.5:8080/a'));
    await client.get(Uri.parse('http://10.0.0.5:8080/b'));

    expect(seen, ['Bearer token-1', 'Bearer token-2']);
  });

  test('NEVER sends the token to another host', () async {
    late http.BaseRequest seen;
    final client = clientWith((request) async {
      seen = request;
      return http.Response('{}', 200);
    });

    for (final other in ['https://evil.example.com/steal', 'http://10.0.0.6:8080/api', 'http://10.0.0.5:9999/api']) {
      await client.get(Uri.parse(other));
      expect(seen.headers.containsKey('Authorization'), isFalse, reason: other);
    }
  });

  test('sends no header when signed out, so the backend answers 401 clearly', () async {
    late http.BaseRequest seen;
    final client = clientWith(
      (request) async {
        seen = request;
        return http.Response('{}', 401);
      },
      idToken: () async => null,
    );

    final response = await client.get(Uri.parse('http://10.0.0.5:8080/api/child/uid-1'));

    expect(seen.headers.containsKey('Authorization'), isFalse);
    expect(response.statusCode, 401);
  });

  test('an unset base URL attaches nothing (nothing is considered "the backend")', () async {
    late http.BaseRequest seen;
    final client = clientWith(
      (request) async {
        seen = request;
        return http.Response('{}', 200);
      },
      baseUrl: '',
    );

    await client.get(Uri.parse('http://10.0.0.5:8080/api'));
    expect(seen.headers.containsKey('Authorization'), isFalse);
  });
}
