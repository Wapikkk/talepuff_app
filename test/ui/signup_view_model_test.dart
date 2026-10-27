import 'package:flutter_test/flutter_test.dart';
import 'package:talepuff_app/data/models/app_message.dart';
import 'package:talepuff_app/data/models/auth_result.dart';
import 'package:talepuff_app/data/services/auth_gateway.dart';
import 'package:talepuff_app/ui/view_models/auth/signup_view_model.dart';
import 'package:talepuff_app/ui/view_models/parents/child_info_view_model.dart';

import '../support/fakes.dart';

class Setup {
  Setup({bool childFilled = true, bool accepted = true}) {
    childInfo = ChildInfoViewModel(repository: fixture.repository);
    viewModel = SignUpViewModel(repository: fixture.repository, childInfoViewModel: childInfo);
    addTearDown(childInfo.dispose);
    addTearDown(viewModel.dispose);

    if (childFilled) {
      childInfo
        ..name = ' Aira '
        ..age = '3'
        ..selectedGender = 'Girl'
        ..selectedInterests.addAll(['Space', 'Music']);
    }
    viewModel
      ..email = 'parent@example.com'
      ..password = 'Secret123'
      ..isAccepted = accepted;
  }

  final fixture = AuthFixture();
  late final ChildInfoViewModel childInfo;
  late final SignUpViewModel viewModel;
}

void main() {
  group('validation (never reaches Firebase)', () {
    test('rejects a bad email', () async {
      final s = Setup();
      s.viewModel.email = 'nope';

      await s.viewModel.signUpManual();

      expect(s.viewModel.error, AppMessage.emailInvalid);
      expect(s.fixture.gateway.calls, isEmpty);
    });

    test('rejects a weak password with an accurate message', () async {
      final s = Setup();
      s.viewModel.password = 'onlyletters';

      await s.viewModel.signUpManual();

      expect(s.viewModel.error, AppMessage.passwordRules);
      expect(s.fixture.gateway.calls, isEmpty);
    });

    test('accepts a password with symbols', () async {
      final s = Setup();
      s.viewModel.password = 'Pass@1234';
      expect(await s.viewModel.signUpManual(), isA<SignedIn>());
    });

    test('requires accepting the terms', () async {
      final s = Setup(accepted: false);
      await s.viewModel.signUpManual();
      expect(s.viewModel.error, AppMessage.termsNotAccepted);
      expect(s.fixture.gateway.calls, isEmpty);
    });

    test("requires the child's information", () async {
      final s = Setup(childFilled: false);
      await s.viewModel.signUpManual();
      expect(s.viewModel.error, AppMessage.childInfoMissing);
      expect(s.fixture.gateway.calls, isEmpty);
    });
  });

  group('email sign-up', () {
    test('registers the trimmed child draft and signs in', () async {
      final s = Setup();

      final result = await s.viewModel.signUpManual();

      expect(result, isA<SignedIn>());
      final registered = s.fixture.api.registered.single;
      expect(registered.name, 'Aira');
      expect(registered.age, 3);
      expect(registered.interests, ['Space', 'Music']);
      expect(s.fixture.session.activeChildId, isNotNull);
    });

    test('an email already in use is reported and nothing is registered', () async {
      final s = Setup();
      s.fixture.gateway.failure = const AuthFailure(AuthGatewayError.emailInUse);

      await s.viewModel.signUpManual();

      expect(s.viewModel.error, AppMessage.emailInUse);
      expect(s.fixture.api.registered, isEmpty);
    });
  });

  group('google', () {
    test('requires the terms and the child form just like email sign-up', () async {
      final noTerms = Setup(accepted: false);
      await noTerms.viewModel.signUpWithGoogle();
      expect(noTerms.fixture.gateway.calls, isEmpty);

      final noChild = Setup(childFilled: false);
      await noChild.viewModel.signUpWithGoogle();
      expect(noChild.fixture.gateway.calls, isEmpty);
    });

    test('an account that already exists is rejected with a "please login" message', () async {
      final s = Setup();
      s.fixture.seedProfile(name: 'Original');

      final result = await s.viewModel.signUpWithGoogle();

      expect(result, isA<AuthFailed>());
      expect(s.viewModel.error, AppMessage.googleAlreadyRegistered);
      expect(s.fixture.api.registered, isEmpty);
    });

    test('a new account registers the child once', () async {
      final s = Setup();
      expect(await s.viewModel.signUpWithGoogle(), isA<SignedIn>());
      expect(s.fixture.api.registered, hasLength(1));
    });

    test('a Google failure is displayed', () async {
      final s = Setup();
      s.fixture.gateway.failure = const AuthFailure(AuthGatewayError.googleSignInFailed, 'sign_in_failed');
      await s.viewModel.signUpWithGoogle();
      expect(s.viewModel.error, AppMessage.googleSignInFailed);
    });
  });
}
