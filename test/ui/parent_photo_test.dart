import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/data/models/account_result.dart';
import 'package:talepuff_app/data/services/auth_gateway.dart';
import 'package:talepuff_app/data/services/profile_photo_service.dart';
import 'package:talepuff_app/ui/view_models/auth/login_view_model.dart';
import 'package:talepuff_app/ui/view_models/parents/child_info_view_model.dart';
import 'package:talepuff_app/ui/view_models/parents/parent_view_model.dart';
import 'package:talepuff_app/ui/views/parent/parent_view.dart';
import 'package:talepuff_app/ui/widgets/parent/child_profile_info.dart';
import 'package:talepuff_app/ui/widgets/shared/top_banner.dart';

import '../support/fakes.dart';

String failureOf(AccountResult result) => (result as AccountFailure).message;

void main() {
  group('ProfilePhotoService', () {
    late File photo;

    setUp(() {
      final dir = Directory.systemTemp.createTempSync('talepuff_photo_test');
      photo = File('${dir.path}/me.jpg')..writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3]);
      addTearDown(() => dir.deleteSync(recursive: true));
    });

    ProfilePhotoService serviceWith(MockClientHandler handler, {Duration timeout = const Duration(seconds: 2)}) =>
        ProfilePhotoService(client: MockClient(handler), baseUrl: 'http://backend/api', timeout: timeout);

    test('uploads the photo as multipart under the "photo" field and returns the stored URL', () async {
      late http.Request seen;
      final service = serviceWith((request) async {
        seen = request;
        return http.Response(jsonEncode({'message': 'ok', 'url': '/uploads/profiles/child-7-1.jpg'}), 200);
      });

      final url = await service.upload(childId: 7, filePath: photo.path);

      expect(url, '/uploads/profiles/child-7-1.jpg');
      expect(seen.method, 'POST');
      expect(seen.url.toString(), 'http://backend/api/child/upload-photo/7');
      expect(seen.headers['content-type'], startsWith('multipart/form-data'));
      final payload = latin1.decode(seen.bodyBytes); // isinya biner (JPEG), jadi bukan UTF-8
      expect(payload, contains('name="photo"'));
      expect(seen.bodyBytes.sublist(seen.bodyBytes.indexOf(0xFF), seen.bodyBytes.indexOf(0xFF) + 4), [0xFF, 0xD8, 0xFF, 0xE0], reason: 'the photo bytes are sent intact');
    });

    test('server errors carry the status code', () async {
      for (final status in [400, 413, 415, 401, 404, 500]) {
        final service = serviceWith((_) async => http.Response('{"error":"x"}', status));
        await expectLater(
          service.upload(childId: 7, filePath: photo.path),
          throwsA(isA<PhotoApiException>().having((e) => e.statusCode, 'statusCode', status)),
          reason: '$status',
        );
      }
    });

    test('a malformed answer, a refused connection, a timeout and an unreadable file all fail cleanly', () async {
      final badBody = serviceWith((_) async => http.Response('not json', 200));
      await expectLater(badBody.upload(childId: 7, filePath: photo.path), throwsA(isA<PhotoApiException>()));

      final noUrl = serviceWith((_) async => http.Response('{"message":"ok"}', 200));
      await expectLater(noUrl.upload(childId: 7, filePath: photo.path), throwsA(isA<PhotoApiException>()));

      final refused = serviceWith((_) async => throw const SocketException('refused'));
      await expectLater(refused.upload(childId: 7, filePath: photo.path), throwsA(isA<PhotoApiException>()));

      final slow = serviceWith(
        (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 300));
          return http.Response('{"url":"/x"}', 200);
        },
        timeout: const Duration(milliseconds: 30),
      );
      await expectLater(slow.upload(childId: 7, filePath: photo.path), throwsA(isA<PhotoApiException>()));

      final ok = serviceWith((_) async => http.Response('{"url":"/x"}', 200));
      await expectLater(
        ok.upload(childId: 7, filePath: '${photo.path}.missing'),
        throwsA(isA<PhotoApiException>().having((e) => e.message, 'message', startsWith('Cannot read the photo'))),
      );
    });

    test('remove sends DELETE for the child and accepts only success', () async {
      late http.Request seen;
      final service = serviceWith((request) async {
        seen = request;
        return http.Response('{"message":"Photo removed"}', 200);
      });

      await service.remove(childId: 7);

      expect(seen.method, 'DELETE');
      expect(seen.url.toString(), 'http://backend/api/child/7/photo');

      final failing = serviceWith((_) async => http.Response('nope', 404));
      await expectLater(
        failing.remove(childId: 7),
        throwsA(isA<PhotoApiException>().having((e) => e.statusCode, 'statusCode', 404)),
      );
    });
  });

  group('a 404 caused by a missing route (backend not restarted) is not "profile not found"', () {
    late File photo;

    setUp(() {
      final dir = Directory.systemTemp.createTempSync('talepuff_photo_404');
      photo = File('${dir.path}/me.jpg')..writeAsBytesSync([0xFF, 0xD8, 0xFF, 0xE0, 1]);
      addTearDown(() => dir.deleteSync(recursive: true));
    });

    ProfilePhotoService serviceWith(MockClientHandler handler) =>
        ProfilePhotoService(client: MockClient(handler), baseUrl: 'http://backend/api');

    test("Gin's plain-text 404 marks the endpoint as missing, our JSON 404 does not", () async {
      final missing = serviceWith((_) async => http.Response('404 page not found', 404));
      await expectLater(
        missing.remove(childId: 7),
        throwsA(isA<PhotoApiException>().having((e) => e.endpointMissing, 'endpointMissing', isTrue)),
      );
      await expectLater(
        missing.upload(childId: 7, filePath: photo.path),
        throwsA(isA<PhotoApiException>().having((e) => e.endpointMissing, 'endpointMissing', isTrue)),
      );

      final notFound = serviceWith((_) async => http.Response('{"error":"Child not found"}', 404));
      await expectLater(
        notFound.remove(childId: 7),
        throwsA(isA<PhotoApiException>().having((e) => e.endpointMissing, 'endpointMissing', isFalse)),
      );
    });

    test('the user is told to restart the backend, not to log in again', () async {
      final api = FakePhotoApi()..error = const PhotoApiException('x', statusCode: 404, endpointMissing: true);
      final message = failureOf(await fakePhotos(api).remove(childId: 7));
      expect(message, contains('restart the backend'));
      expect(message, isNot(contains('login again')));
    });

    test('a real "child not found" still asks to log in again', () async {
      final api = FakePhotoApi()..error = const PhotoApiException('x', statusCode: 404);
      expect(failureOf(await fakePhotos(api).remove(childId: 7)), contains('login again'));
    });
  });

  group('ProfilePhotoRepository messages', () {
    test('map to clear sentences', () async {
      final expectations = {
        400: 'supported photo',
        415: 'supported photo',
        413: 'too large',
        401: 'login again',
        403: 'login again',
        404: "couldn't find this child's profile",
        500: "Can't reach the server",
      };
      for (final entry in expectations.entries) {
        final api = FakePhotoApi()..error = PhotoApiException('x', statusCode: entry.key);
        final result = await fakePhotos(api).upload(childId: 7, filePath: 'a.jpg');
        expect(failureOf(result), contains(entry.value), reason: '${entry.key}');
      }
    });

    test('an unreadable file and a network failure are told apart', () async {
      final unreadable = FakePhotoApi()..error = const PhotoApiException('Cannot read the photo: gone');
      expect(failureOf(await fakePhotos(unreadable).upload(childId: 7, filePath: 'a.jpg')), contains("couldn't read"));

      final down = FakePhotoApi()..error = const PhotoApiException('Cannot reach the server: refused');
      expect(failureOf(await fakePhotos(down).upload(childId: 7, filePath: 'a.jpg')), contains("Can't reach the server"));
    });
  });

  group('ParentViewModel photo handling', () {
    ParentViewModel make(FakePhotoApi api, {String? photoUrl = '/uploads/profiles/old.jpg'}) {
      return ParentViewModel(photos: fakePhotos(api))..setInitiateData('7', photoUrl, 'Aira');
    }

    test('a successful upload switches to the new photo and clears the preview', () async {
      final api = FakePhotoApi();
      final viewModel = make(api);

      final result = await viewModel.uploadProfilePhoto('7', File('new.jpg'));

      expect(result, isA<AccountSuccess>());
      expect(viewModel.currentPhotoUrl, '/uploads/profiles/new.jpg');
      expect(viewModel.imagePreview, isNull);
      expect(viewModel.isUploading, isFalse);
      expect(api.uploads, ['7:new.jpg']);
    });

    test('a failed upload brings the previous photo back and reports why', () async {
      final api = FakePhotoApi()..error = const PhotoApiException('big', statusCode: 413);
      final viewModel = make(api);

      final result = await viewModel.uploadProfilePhoto('7', File('big.jpg'));

      expect(failureOf(result!), contains('too large'));
      expect(viewModel.currentPhotoUrl, '/uploads/profiles/old.jpg', reason: 'the old photo stays');
      expect(viewModel.imagePreview, isNull, reason: 'the failed preview is dropped');
      expect(viewModel.isUploading, isFalse);
    });

    test('the new photo is previewed while it uploads', () async {
      final api = FakePhotoApi()..gate = Completer<void>();
      final viewModel = make(api);

      final pending = viewModel.uploadProfilePhoto('7', File('new.jpg'));
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.imagePreview?.path, 'new.jpg');
      expect(viewModel.isUploading, isTrue);

      api.gate!.complete();
      await pending;
      expect(viewModel.imagePreview, isNull);
    });

    test('a second action while one is running is ignored', () async {
      final api = FakePhotoApi()..gate = Completer<void>();
      final viewModel = make(api);

      final first = viewModel.uploadProfilePhoto('7', File('a.jpg'));
      expect(await viewModel.uploadProfilePhoto('7', File('b.jpg')), isNull);
      expect(await viewModel.removePhoto(), isNull);

      api.gate!.complete();
      await first;
      expect(api.uploads, ['7:a.jpg']);
    });

    test('remove deletes on the server and only then clears the photo', () async {
      final api = FakePhotoApi();
      final viewModel = make(api);

      final result = await viewModel.removePhoto();

      expect(result, isA<AccountSuccess>());
      expect(viewModel.currentPhotoUrl, isNull);
      expect(api.removals, [7]);
    });

    test('a failed remove keeps the photo, so it does not "come back" after a restart', () async {
      final api = FakePhotoApi()..error = const PhotoApiException('down');
      final viewModel = make(api);

      final result = await viewModel.removePhoto();

      expect(result, isA<AccountFailure>());
      expect(viewModel.currentPhotoUrl, '/uploads/profiles/old.jpg');
    });

    test('without a loaded child there is a clear message and nothing is sent', () async {
      final api = FakePhotoApi();
      final viewModel = ParentViewModel(photos: fakePhotos(api));

      expect(failureOf((await viewModel.removePhoto())!), contains('not been loaded'));
      expect(failureOf((await viewModel.uploadProfilePhoto('null', File('a.jpg')))!), contains('not been loaded'));
      expect(api.uploads, isEmpty);
      expect(api.removals, isEmpty);
    });
  });

  group('TopBanner error style', () {
    testWidgets('shows the message with an error icon instead of the success check', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(children: [
              ElevatedButton(
                onPressed: () => TopBanner.show(TopBanner.overlayOf(context), 'Upload failed', type: TopBannerType.error),
                child: const Text('go'),
              ),
              ElevatedButton(
                onPressed: () => TopBanner.show(TopBanner.overlayOf(context), 'Saved'),
                child: const Text('ok'),
              ),
            ]),
          ),
        ),
      ));

      await tester.tap(find.text('go'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('Upload failed'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsNothing);

      await tester.tap(find.text('ok'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });
  });

  group('ChildProfileInfo text', () {
    Widget show({String age = '3', List<String> interests = const ['Space', 'Music']}) {
      return MaterialApp(
        home: Scaffold(body: ChildProfileInfo(name: 'Aira', age: age, email: 'a@x.com', interests: interests)),
      );
    }

    testWidgets('shows "3 years old" instead of "3th"', (tester) async {
      await tester.pumpWidget(show());
      expect(find.text('Aira, 3 years old'), findsOneWidget);
      expect(find.textContaining('3th'), findsNothing);
    });

    test('age wording', () {
      expect(ChildProfileInfo.ageText('1'), '1 year old');
      expect(ChildProfileInfo.ageText('4'), '4 years old');
      expect(ChildProfileInfo.ageText(' 5 '), '5 years old');
      for (final none in ['', '  ', '0', '-2', 'abc']) {
        expect(ChildProfileInfo.ageText(none), '', reason: none);
      }
    });

    testWidgets('an empty age shows only the name (no dangling "th")', (tester) async {
      await tester.pumpWidget(show(age: ''));
      expect(find.text('Aira'), findsOneWidget);
    });

    testWidgets('the interests sentence starts with a capital "I"', (tester) async {
      await tester.pumpWidget(show());
      expect(find.text("Hi, I'm Aira, I like Space and Music!"), findsOneWidget);

      await tester.pumpWidget(show(interests: const ['Space']));
      expect(find.text("Hi, I'm Aira, I like Space!"), findsOneWidget);

      await tester.pumpWidget(show(interests: const ['Space', 'Music', 'Art']));
      expect(find.text("Hi, I'm Aira, I like Space, Music, and Art!"), findsOneWidget);
    });
  });

  group('the Parent page', () {
    testWidgets('no longer shows placeholder numbers or the unfinished schedule', (tester) async {
      final fixture = AuthFixture(signedInUser: const AuthUser('uid-1', 'parent@example.com'));
      fixture.seedProfile(name: 'Aira');
      final childInfo = ChildInfoViewModel(repository: fixture.repository)..applySavedName('Aira');
      final parent = ParentViewModel(photos: fakePhotos())..setInitiateData('7', null, 'Aira');

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: childInfo),
          ChangeNotifierProvider.value(value: parent),
          ChangeNotifierProvider(create: (_) => LoginViewModel(repository: fixture.repository)),
        ],
        child: const MaterialApp(home: ParentView()),
      ));
      await tester.pump();

      expect(find.text('Aira'), findsWidgets);
      expect(find.text('Auto Bedtime Story'), findsNothing);
      expect(find.textContaining('listening week overview'), findsNothing);
      expect(find.textContaining('Stories'), findsNothing);
      expect(find.textContaining('Minutes'), findsNothing);
    });
  });
}
