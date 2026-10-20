import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:talepuff_app/data/repositories/auth_repository.dart';
import 'package:talepuff_app/data/services/auth_gateway.dart';
import 'package:talepuff_app/data/services/auth_service.dart';
import 'package:talepuff_app/data/services/authenticated_client.dart';
import 'package:talepuff_app/ui/view_models/parents/child_info_view_model.dart';

import '../support/fakes.dart';

/// Rangkaian ASLI yang dipakai aplikasi (AuthenticatedClient -> AuthService -> AuthRepository) dengan
/// hanya jaringan yang dipalsukan. Tes ini ada karena kegagalan "nama jadi Friend" lolos dari tes yang
/// memakai objek palsu: ViewModel membuat AuthService sendiri tanpa token, dan backend menjawab 401.
class Wired {
  Wired(MockClientHandler handler, {AuthUser? user}) {
    final client = AuthenticatedClient(
      idToken: () async => 'tok-1',
      baseUrl: () => 'http://backend',
      inner: MockClient((request) async {
        requests.add(request);
        // Meniru backend: tanpa token jawabannya 401 (inilah yang membuat nama jadi "Friend").
        if (!request.headers.containsKey('Authorization')) return http.Response('{"error":"Missing token"}', 401);
        return handler(request);
      }),
    );
    repository = AuthRepository(
      gateway: FakeGateway(user: user ?? const AuthUser('uid-1', 'p@x.com')),
      api: AuthService(client: client, baseUrl: 'http://backend/api'),
      session: FakeSessionStore(),
    );
  }

  final requests = <http.BaseRequest>[];
  late final AuthRepository repository;
}

http.Response profile({Object? age = 3, List<String> interests = const ['Space', 'Music'], Map<String, Object?> extra = const {}}) {
  return http.Response(
    jsonEncode({'ID': 7, 'name': 'Aira', 'age': age, 'interests': interests, ...extra}),
    200,
  );
}

void main() {
  group('ChildInfoViewModel.syncChildData (what Home and Parent show after an app restart)', () {
    test('fills in name, age and interests, sending the token', () async {
      final wired = Wired((_) async => profile());
      final viewModel = ChildInfoViewModel(repository: wired.repository);

      expect(viewModel.childName, 'Friend');
      await viewModel.syncChildData();

      expect(viewModel.childName, 'Aira');
      expect(viewModel.age, '3');
      expect(viewModel.selectedInterests, ['Space', 'Music']);
      expect(wired.requests.single.headers['Authorization'], 'Bearer tok-1', reason: 'no token = 401 = the "Friend" bug');
      expect(wired.requests.single.url.toString(), 'http://backend/api/child/uid-1');
    });

    test('the saved profile replaces a stale draft left by the registration form', () async {
      final viewModel = ChildInfoViewModel(repository: Wired((_) async => profile()).repository)
        ..name = 'Old Draft'
        ..age = '9';

      await viewModel.syncChildData();

      expect(viewModel.childName, 'Aira');
      expect(viewModel.age, '3');
    });

    test('an age of 0 (nothing was entered) shows as empty', () async {
      final viewModel = ChildInfoViewModel(repository: Wired((_) async => profile(age: 0)).repository);
      await viewModel.syncChildData();
      expect(viewModel.age, '');
    });

    test('syncing twice does not duplicate the interests', () async {
      final viewModel = ChildInfoViewModel(repository: Wired((_) async => profile()).repository);
      await viewModel.syncChildData();
      await viewModel.syncChildData();
      expect(viewModel.selectedInterests, ['Space', 'Music']);
    });

    test('a rejected session (401), a missing profile and an unreachable server leave the data alone', () async {
      for (final response in [401, 403, 404, 500]) {
        final viewModel = ChildInfoViewModel(repository: Wired((_) async => http.Response('', response)).repository);
        await viewModel.syncChildData();

        expect(viewModel.childName, 'Friend', reason: '$response');
        expect(viewModel.selectedInterests, isEmpty, reason: '$response');
      }
    });

    test('with nobody signed in, nothing is requested', () async {
      final signedOut = AuthRepository(
        gateway: FakeGateway(),
        api: AuthService(client: unusedHttpClient(), baseUrl: 'http://backend/api'), // menyentuh jaringan = tes gagal
        session: FakeSessionStore(),
      );
      final viewModel = ChildInfoViewModel(repository: signedOut);

      await viewModel.syncChildData();

      expect(viewModel.childName, 'Friend');
    });
  });

  group('AuthRepository.currentProfile', () {
    test('signed out -> "no profile", without any request', () async {
      final repository = AuthRepository(
        gateway: FakeGateway(),
        api: AuthService(client: unusedHttpClient(), baseUrl: 'http://backend/api'),
        session: FakeSessionStore(),
      );
      expect(await repository.currentProfile(), isA<ProfileNotFound>());
    });

    test('signed in -> looks up the profile of the signed-in uid', () async {
      final wired = Wired((_) async => profile(), user: const AuthUser('uid-xyz', null));
      expect(await wired.repository.currentProfile(), isA<ProfileFound>());
      expect(wired.requests.single.url.path, '/api/child/uid-xyz');
    });
  });
}
