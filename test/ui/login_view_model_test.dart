import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talepuff_app/data/models/auth_result.dart';
import 'package:talepuff_app/data/services/auth_gateway.dart';
import 'package:talepuff_app/ui/view_models/auth/login_view_model.dart';

import '../support/fakes.dart';

LoginViewModel makeViewModel(AuthFixture f) {
  final viewModel = LoginViewModel(repository: f.repository);
  addTearDown(viewModel.dispose);
  return viewModel;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('input validation (never reaches Firebase)', () {
    test('empty fields are rejected with the required message', () async {
      final f = AuthFixture();
      final vm = makeViewModel(f);

      final result = await vm.login();

      expect(result, isA<AuthFailed>());
      expect(vm.errorMessage, 'Email and Password are required!');
      expect(f.gateway.calls, isEmpty);
    });

    test('a malformed email is rejected', () async {
      final f = AuthFixture();
      final vm = makeViewModel(f)
        ..email = 'not-an-email'
        ..password = 'whatever1';

      await vm.login();

      expect(vm.errorMessage, contains('Invalid email'));
      expect(f.gateway.calls, isEmpty);
    });

    test('an old password that fails the NEW password rules can still sign in', () async {
      final f = AuthFixture();
      f.seedProfile();
      final vm = makeViewModel(f)
        ..email = 'parent@example.com'
        ..password = 'abc'; // lebih pendek dari aturan pendaftaran

      expect(await vm.login(), isA<SignedIn>());
    });
  });

  group('login', () {
    test('success returns SignedIn, trims the email and clears the loading state', () async {
      final f = AuthFixture();
      f.seedProfile();
      final vm = makeViewModel(f)
        ..email = '  parent@example.com  '
        ..password = 'secret123';

      final result = await vm.login();

      expect(result, isA<SignedIn>());
      expect(f.gateway.calls, ['signIn:parent@example.com']);
      expect(vm.isLoading, isFalse);
      expect(vm.errorMessage, isNull);
    });

    test('a failure shows the repository message', () async {
      final f = AuthFixture();
      f.gateway.failure = const AuthFailure(AuthGatewayError.invalidCredentials);
      final vm = makeViewModel(f)
        ..email = 'parent@example.com'
        ..password = 'wrong-one1';

      await vm.login();

      expect(vm.errorMessage, contains('Incorrect email or password'));
      expect(vm.isLoading, isFalse);
    });

    test('an account without a profile returns NeedsProfile (not an error message)', () async {
      final f = AuthFixture();
      final vm = makeViewModel(f)
        ..email = 'parent@example.com'
        ..password = 'secret123';

      expect(await vm.login(), isA<NeedsProfile>());
      expect(vm.errorMessage, isNull);
    });

    test('a second tap while the first is running is ignored', () async {
      final f = AuthFixture();
      f.seedProfile();
      f.gateway.gate = Completer<void>();
      final vm = makeViewModel(f)
        ..email = 'parent@example.com'
        ..password = 'secret123';

      final first = vm.login();
      await Future<void>.delayed(Duration.zero);
      expect(vm.isLoading, isTrue);
      expect(vm.activeMethod, AuthMethod.email);

      expect(await vm.login(), isA<AuthCancelled>());

      f.gateway.gate!.complete();
      expect(await first, isA<SignedIn>());
      expect(f.gateway.calls, hasLength(1));
    });
  });

  group('remember me', () {
    test('saves the email after a successful login when enabled', () async {
      final f = AuthFixture();
      f.seedProfile();
      final vm = makeViewModel(f)
        ..email = 'parent@example.com'
        ..password = 'secret123'
        ..rememberMe = true;

      await vm.login();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LoginViewModel.savedEmailKey), 'parent@example.com');
    });

    test('removes a previously saved email when disabled', () async {
      SharedPreferences.setMockInitialValues({LoginViewModel.savedEmailKey: 'old@example.com'});
      final f = AuthFixture();
      f.seedProfile();
      final vm = makeViewModel(f)
        ..email = 'parent@example.com'
        ..password = 'secret123';

      await vm.login();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LoginViewModel.savedEmailKey), isNull);
    });

    test('does not save anything when the login fails', () async {
      final f = AuthFixture();
      f.gateway.failure = const AuthFailure(AuthGatewayError.invalidCredentials);
      final vm = makeViewModel(f)
        ..email = 'parent@example.com'
        ..password = 'wrong-one1'
        ..rememberMe = true;

      await vm.login();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(LoginViewModel.savedEmailKey), isNull);
    });

    test('loadSavedEmail restores the email and the checkbox', () async {
      SharedPreferences.setMockInitialValues({LoginViewModel.savedEmailKey: 'saved@example.com'});
      final vm = makeViewModel(AuthFixture());

      await vm.loadSavedEmail();

      expect(vm.email, 'saved@example.com');
      expect(vm.rememberMe, isTrue);
    });
  });

  group('google', () {
    test('an existing account signs in and the loading state is reported for google', () async {
      final f = AuthFixture();
      f.seedProfile();
      final vm = makeViewModel(f);
      final methods = <AuthMethod?>[];
      vm.addListener(() => methods.add(vm.activeMethod));

      final result = await vm.loginWithGoogle();

      expect(result, isA<SignedIn>());
      expect(methods, contains(AuthMethod.google));
      expect(vm.activeMethod, isNull);
    });

    test('cancelling shows no error', () async {
      final f = AuthFixture();
      f.gateway.failure = const AuthFailure(AuthGatewayError.cancelled);
      final vm = makeViewModel(f);

      expect(await vm.loginWithGoogle(), isA<AuthCancelled>());
      expect(vm.errorMessage, isNull);
    });

    test('a Google error is shown to the user instead of being swallowed', () async {
      final f = AuthFixture();
      f.gateway.failure = const AuthFailure(AuthGatewayError.unknown, 'Google sign-in failed.');
      final vm = makeViewModel(f);

      await vm.loginWithGoogle();

      expect(vm.errorMessage, 'Google sign-in failed.');
    });
  });

  group('session data', () {
    test('applySession fills the getters used by other screens', () async {
      final f = AuthFixture();
      final profile = f.seedProfile(id: 5, name: 'Aira');
      final vm = makeViewModel(f)..password = 'left-over';

      vm.applySession(SignedIn(profile, email: 'parent@example.com'));

      expect(vm.currentChildId, '5');
      expect(vm.childName, 'Aira');
      expect(vm.email, 'parent@example.com');
      expect(vm.password, isEmpty);
    });

    test('logout signs out and clears the session data', () async {
      final f = AuthFixture();
      final profile = f.seedProfile(id: 5);
      final vm = makeViewModel(f)..applySession(SignedIn(profile, email: 'p@x.com'));

      await vm.logout();

      expect(f.gateway.signOutCalls, 1);
      expect(f.session.clears, 1);
      expect(vm.currentChildId, isNull);
      expect(vm.email, isEmpty);
    });
  });
}
