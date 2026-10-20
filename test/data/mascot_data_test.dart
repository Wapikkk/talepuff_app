import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:talepuff_app/core/mascots.dart';
import 'package:talepuff_app/data/models/account_result.dart';
import 'package:talepuff_app/data/models/child_profile.dart';
import 'package:talepuff_app/data/services/auth_gateway.dart';
import 'package:talepuff_app/data/services/auth_service.dart';
import 'package:talepuff_app/ui/view_models/parents/child_info_view_model.dart';

import '../support/fakes.dart';

String failureOf(AccountResult result) => (result as AccountFailure).message;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mascots catalog', () {
    test('has the same ids as the backend (validation.Mascots), in the same order', () {
      expect(Mascots.all.map((m) => m.id).toList(), ['Harimau', 'OrangUtan', 'Badak', 'Burung']);
      expect(Mascots.defaultId, 'Harimau');
    });

    test('every mascot has a unique id and its image is really bundled', () async {
      expect(Mascots.all.map((m) => m.id).toSet().length, Mascots.all.length);
      for (final mascot in Mascots.all) {
        final bytes = await rootBundle.load(mascot.asset);
        expect(bytes.lengthInBytes, greaterThan(0), reason: mascot.asset);
      }
    });

    test('an unknown id falls back to the default instead of failing', () {
      expect(Mascots.byId('Badak').id, 'Badak');
      expect(Mascots.byId('Naga').id, 'Harimau');
      expect(Mascots.byId('').id, 'Harimau');
      expect(Mascots.isValid('Burung'), isTrue);
      expect(Mascots.isValid('burung'), isFalse);
    });
  });

  group('ChildProfile.fromJson mascot', () {
    Map<String, Object?> json(Object? mascot) => {'ID': 7, 'name': 'Aira', if (mascot != null) 'mascot_id': mascot};

    test('reads a valid mascot', () => expect(ChildProfile.fromJson(json('Badak')).mascotId, 'Badak'));

    test('a missing, empty or unknown mascot becomes the default', () {
      for (final value in [null, '', 'Naga', 5]) {
        expect(ChildProfile.fromJson(json(value)).mascotId, 'Harimau', reason: '$value');
      }
    });
  });

  group('AuthService.updateMascot', () {
    AuthService serviceWith(MockClientHandler handler) =>
        AuthService(client: MockClient(handler), baseUrl: 'http://backend/api');

    test('PUTs the mascot id for the child', () async {
      late http.Request seen;
      final service = serviceWith((request) async {
        seen = request;
        return http.Response('{"mascot_id":"Badak"}', 200);
      });

      await service.updateMascot(childId: 7, mascotId: 'Badak');

      expect(seen.method, 'PUT');
      expect(seen.url.toString(), 'http://backend/api/child/7/mascot');
      expect(jsonDecode(seen.body), {'mascot_id': 'Badak'});
    });

    test("Gin's plain-text 404 means the route is missing; a JSON 404 means the child is", () async {
      final missing = serviceWith((_) async => http.Response('404 page not found', 404));
      await expectLater(
        missing.updateMascot(childId: 7, mascotId: 'Badak'),
        throwsA(isA<ProfileApiException>().having((e) => e.endpointMissing, 'endpointMissing', isTrue)),
      );

      final notFound = serviceWith((_) async => http.Response('{"error":"Child not found"}', 404));
      await expectLater(
        notFound.updateMascot(childId: 7, mascotId: 'Badak'),
        throwsA(isA<ProfileApiException>().having((e) => e.endpointMissing, 'endpointMissing', isFalse)),
      );
    });
  });

  group('AccountRepository.updateMascot', () {
    test('saves the choice and reports it back', () async {
      final f = AccountFixture();
      final result = await f.repository.updateMascot(childId: 7, mascotId: 'Burung');

      expect(result, isA<AccountSuccess>());
      expect((result as AccountSuccess).value, 'Burung');
      expect(f.api.mascots, ['7:Burung']);
    });

    test('an id outside the catalog never reaches the server', () async {
      final f = AccountFixture();
      for (final bad in ['', 'Naga', 'badak']) {
        expect(await f.repository.updateMascot(childId: 7, mascotId: bad), isA<AccountFailure>(), reason: bad);
      }
      expect(f.api.mascots, isEmpty);
    });

    test('server answers map to specific messages', () async {
      final expectations = {
        400: "didn't accept this mascot",
        401: 'login again',
        403: 'login again',
        404: "couldn't find this child's profile",
        500: "Can't reach the server",
      };
      for (final entry in expectations.entries) {
        final f = AccountFixture()..api.mascotError = ProfileApiException('x', statusCode: entry.key);
        expect(failureOf(await f.repository.updateMascot(childId: 7, mascotId: 'Badak')), contains(entry.value), reason: '${entry.key}');
      }
    });

    test('a backend that was not restarted is explained, not reported as a missing profile', () async {
      final f = AccountFixture()..api.mascotError = const ProfileApiException('x', statusCode: 404, endpointMissing: true);
      final message = failureOf(await f.repository.updateMascot(childId: 7, mascotId: 'Badak'));
      expect(message, contains('restart the backend'));
      expect(message, isNot(contains('login again')));
    });
  });

  group('ChildInfoViewModel as the single source of the child data', () {
    ChildInfoViewModel make() => ChildInfoViewModel(repository: AuthFixture().repository);

    test('applyProfile fills in name, age, interests and mascot, and drops a stale draft', () {
      final viewModel = make()..name = 'Old draft';
      var notified = 0;
      viewModel.addListener(() => notified++);

      viewModel.applyProfile(const ChildProfile(id: 7, name: 'Aira', age: 3, interests: ['Space', 'Music'], mascotId: 'Badak'));

      expect(viewModel.childName, 'Aira');
      expect(viewModel.age, '3');
      expect(viewModel.selectedInterests, ['Space', 'Music']);
      expect(viewModel.mascotId, 'Badak');
      expect(notified, 1);
    });

    test('applyMascot changes only the mascot, and ignores an unknown id', () {
      final viewModel = make();
      viewModel.applyMascot('Burung');
      expect(viewModel.mascotId, 'Burung');

      viewModel.applyMascot('Naga');
      expect(viewModel.mascotId, 'Harimau');
    });

    test('reset (logout) returns to the default mascot', () {
      final viewModel = make()..applyMascot('Badak');
      viewModel.reset();
      expect(viewModel.mascotId, 'Harimau');
    });

    test('syncChildData brings the saved mascot too', () async {
      final f = AuthFixture(signedInUser: const AuthUser('uid-1', null));
      f.api.store['uid-1'] = const ChildProfile(id: 7, name: 'Aira', mascotId: 'OrangUtan');
      final viewModel = ChildInfoViewModel(repository: f.repository);

      await viewModel.syncChildData();

      expect(viewModel.mascotId, 'OrangUtan');
    });
  });
}
