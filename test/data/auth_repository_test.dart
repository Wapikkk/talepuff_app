import 'package:flutter_test/flutter_test.dart';
import 'package:talepuff_app/data/models/app_message.dart';
import 'package:talepuff_app/data/models/auth_result.dart';
import 'package:talepuff_app/data/services/auth_gateway.dart';
import 'package:talepuff_app/data/services/auth_service.dart';

import '../support/fakes.dart';

void main() {
  group('restoreSession', () {
    test('without a saved session the user is signed out', () async {
      final f = AuthFixture();
      expect(await f.repository.restoreSession(), isA<SignedOut>());
      expect(f.api.fetchCalls, 0);
    });

    test('a saved session with a profile enters the app and remembers the active child', () async {
      final f = AuthFixture(signedInUser: const AuthUser('uid-1', 'parent@example.com'));
      final profile = f.seedProfile();

      final result = await f.repository.restoreSession();

      expect(result, isA<SignedIn>());
      expect((result as SignedIn).profile.id, profile.id);
      expect(result.email, 'parent@example.com');
      expect(f.session.activeChildId, profile.id);
    });

    test('a saved session without a profile asks to complete the profile', () async {
      final f = AuthFixture(signedInUser: const AuthUser('uid-1', null));
      expect(await f.repository.restoreSession(), isA<NeedsProfile>());
      expect(f.session.activeChildId, isNull);
    });

    test('an unreachable server is reported as a network problem, not as a missing profile', () async {
      final f = AuthFixture(signedInUser: const AuthUser('uid-1', null));
      f.api.forcedLookup = const ProfileUnreachable('timeout');

      final result = await f.repository.restoreSession();

      expect(result, isA<AuthFailed>());
      expect((result as AuthFailed).reason, AuthFailureReason.network);
      expect(f.session.activeChildId, isNull);
    });
  });

  group('signInWithEmail', () {
    test('success with a profile signs in and stores the active child', () async {
      final f = AuthFixture();
      f.seedProfile(id: 9);

      final result = await f.repository.signInWithEmail('parent@example.com', 'secret123');

      expect(result, isA<SignedIn>());
      expect(f.session.activeChildId, 9);
    });

    test('success without a profile asks to complete the profile', () async {
      final f = AuthFixture();
      expect(await f.repository.signInWithEmail('parent@example.com', 'secret123'), isA<NeedsProfile>());
    });

    test('wrong credentials give a clear message and never touch the backend', () async {
      final f = AuthFixture();
      f.gateway.failure = const AuthFailure(AuthGatewayError.invalidCredentials);

      final result = await f.repository.signInWithEmail('parent@example.com', 'nope');

      expect(result, isA<AuthFailed>());
      expect((result as AuthFailed).reason, AuthFailureReason.invalidCredentials);
      expect(result.message, AppMessage.invalidCredentials);
      expect(f.api.fetchCalls, 0);
    });

    test('network problem at sign-in is mapped to the network reason', () async {
      final f = AuthFixture();
      f.gateway.failure = const AuthFailure(AuthGatewayError.network);
      final result = await f.repository.signInWithEmail('a@b.com', 'x') as AuthFailed;
      expect(result.reason, AuthFailureReason.network);
    });
  });

  group('a rejected session (401/403 from the backend)', () {
    test('signing in reports it instead of "can\'t reach the server" or "no profile"', () async {
      final f = AuthFixture();
      f.api.forcedLookup = const ProfileRejected();

      final result = await f.repository.signInWithEmail('p@x.com', 'abcd1234') as AuthFailed;

      expect(result.message, AppMessage.sessionRejected);
      expect(result.message, isNot(AppMessage.serverUnreachable));
    });

    test('restoring a saved session reports it too', () async {
      final f = AuthFixture(signedInUser: const AuthUser('uid-1', 'p@x.com'));
      f.api.forcedLookup = const ProfileRejected();
      expect(await f.repository.restoreSession(), isA<AuthFailed>());
    });

    test('register answered with 401 is a session problem, not "could not save the profile"', () async {
      final f = AuthFixture();
      f.api.registerError = const ProfileApiException('unauthorized', statusCode: 401);

      final result = await f.repository.signUpWithEmail('p@x.com', 'abcd1234', childDraft) as AuthFailed;

      expect(result.message, AppMessage.sessionRejected);
    });
  });

  group('register answered with 409 (profile already stored by the backend)', () {
    test('is treated as "already registered": the stored profile is fetched, not an error', () async {
      final f = AuthFixture();
      f.seedProfile(name: 'Stored Name', id: 4);
      f.api.registerError = const ProfileApiException('conflict', statusCode: 409);

      final result = await f.repository.signUpWithEmail('p@x.com', 'abcd1234', childDraft);

      expect(result, isA<SignedIn>());
      expect((result as SignedIn).profile.name, 'Stored Name');
    });

    test('any other status still fails', () async {
      final f = AuthFixture();
      f.api.registerError = const ProfileApiException('bad', statusCode: 400);
      final result = await f.repository.signUpWithEmail('p@x.com', 'abcd1234', childDraft);
      expect(result, isA<AuthFailed>());
    });
  });

  group('signUpWithEmail', () {
    test('registers the child exactly once and enters the app', () async {
      final f = AuthFixture();

      final result = await f.repository.signUpWithEmail('parent@example.com', 'secret123', childDraft);

      expect(result, isA<SignedIn>());
      expect(f.api.registered, [childDraft]);
      expect(f.session.activeChildId, isNotNull);
    });

    test('an email already in use fails without registering anything', () async {
      final f = AuthFixture();
      f.gateway.failure = const AuthFailure(AuthGatewayError.emailInUse);

      final result = await f.repository.signUpWithEmail('parent@example.com', 'secret123', childDraft);

      expect((result as AuthFailed).reason, AuthFailureReason.emailInUse);
      expect(f.api.registered, isEmpty);
    });

    test('when the backend fails the account exists but the user is told to retry, session untouched', () async {
      final f = AuthFixture();
      f.api.registerError = const ProfileApiException('boom', statusCode: 500);

      final result = await f.repository.signUpWithEmail('parent@example.com', 'secret123', childDraft);

      expect((result as AuthFailed).reason, AuthFailureReason.profileSyncFailed);
      expect(f.session.activeChildId, isNull);
      // Firebase tetap punya akun ini, sehingga pembukaan aplikasi berikutnya menuju "lengkapi profil".
      expect(f.gateway.currentUser, isNotNull);
    });
  });

  group('continueWithGoogle', () {
    test('closing the account picker is a cancellation, not an error', () async {
      final f = AuthFixture();
      f.gateway.failure = const AuthFailure(AuthGatewayError.cancelled);
      expect(await f.repository.continueWithGoogle(child: childDraft), isA<AuthCancelled>());
    });

    test('an existing profile signs in WITHOUT registering again (no overwrite of the child data)', () async {
      final f = AuthFixture();
      final existing = f.seedProfile(name: 'Original Name', id: 4);

      final result = await f.repository.continueWithGoogle(child: childDraft);

      expect(result, isA<SignedIn>());
      expect((result as SignedIn).profile.name, existing.name);
      expect(f.api.registered, isEmpty, reason: 'register would overwrite the existing child on the backend');
      expect(f.session.activeChildId, 4);
    });

    test('a new account with a child form registers once and signs in', () async {
      final f = AuthFixture();

      final result = await f.repository.continueWithGoogle(child: childDraft);

      expect(result, isA<SignedIn>());
      expect(f.api.registered, [childDraft]);
    });

    test('a new account without a child form asks to complete the profile', () async {
      final f = AuthFixture();
      expect(await f.repository.continueWithGoogle(), isA<NeedsProfile>());
      expect(f.api.registered, isEmpty);
    });

    test('an unreachable server fails without registering', () async {
      final f = AuthFixture();
      f.api.forcedLookup = const ProfileUnreachable('down');

      final result = await f.repository.continueWithGoogle(child: childDraft);

      expect((result as AuthFailed).reason, AuthFailureReason.network);
      expect(f.api.registered, isEmpty);
    });

    test('a Google configuration failure (sign_in_failed) has its own message code', () async {
      final f = AuthFixture();
      f.gateway.failure = const AuthFailure(AuthGatewayError.googleSignInFailed, 'sign_in_failed');
      final result = await f.repository.continueWithGoogle() as AuthFailed;
      expect(result.message, AppMessage.googleSignInFailed);
    });

    test('an unexpected Google error becomes the generic message (detail is only logged)', () async {
      final f = AuthFixture();
      f.gateway.failure = const AuthFailure(AuthGatewayError.unknown, 'platform detail');
      final result = await f.repository.continueWithGoogle() as AuthFailed;
      expect(result.message, AppMessage.genericError);
    });
  });

  group('completeProfile', () {
    test('without a session the user is signed out', () async {
      final f = AuthFixture();
      expect(await f.repository.completeProfile(childDraft), isA<SignedOut>());
    });

    test('registers when the profile is missing', () async {
      final f = AuthFixture(signedInUser: const AuthUser('uid-1', 'parent@example.com'));
      expect(await f.repository.completeProfile(childDraft), isA<SignedIn>());
      expect(f.api.registered, [childDraft]);
    });

    test('never overwrites a profile that already exists', () async {
      final f = AuthFixture(signedInUser: const AuthUser('uid-1', 'parent@example.com'));
      f.seedProfile(name: 'Original Name');

      final result = await f.repository.completeProfile(childDraft);

      expect((result as SignedIn).profile.name, 'Original Name');
      expect(f.api.registered, isEmpty);
    });

    test('an unreachable server does not register', () async {
      final f = AuthFixture(signedInUser: const AuthUser('uid-1', null));
      f.api.forcedLookup = const ProfileUnreachable('down');
      expect(await f.repository.completeProfile(childDraft), isA<AuthFailed>());
      expect(f.api.registered, isEmpty);
    });
  });

  test('signOut signs out of the gateway and forgets the active child', () async {
    final f = AuthFixture(signedInUser: const AuthUser('uid-1', null));
    f.seedProfile();
    await f.repository.restoreSession();
    expect(f.session.activeChildId, isNotNull);

    await f.repository.signOut();

    expect(f.gateway.signOutCalls, 1);
    expect(f.session.activeChildId, isNull);
    expect(f.repository.currentEmail, isNull);
  });

  group('signUpWithGoogle (Sign Up screen)', () {
    test('an account that already has a profile is rejected, signed out, and left untouched', () async {
      final f = AuthFixture();
      f.seedProfile(name: 'Original Name', id: 4);

      final result = await f.repository.signUpWithGoogle(childDraft);

      expect(result, isA<AuthFailed>());
      expect((result as AuthFailed).reason, AuthFailureReason.alreadyRegistered);
      expect(f.gateway.signOutCalls, 1, reason: 'the Firebase/Google session must not stay half-open');
      expect(f.session.activeChildId, isNull);
      expect(f.api.registered, isEmpty, reason: 'register would overwrite the existing child');
    });

    test('a brand-new account registers the child and enters', () async {
      final f = AuthFixture();
      expect(await f.repository.signUpWithGoogle(childDraft), isA<SignedIn>());
      expect(f.api.registered, hasLength(1));
    });

    test('cancelling the Google chooser is not an error', () async {
      final f = AuthFixture();
      f.gateway.failure = const AuthFailure(AuthGatewayError.cancelled);
      expect(await f.repository.signUpWithGoogle(childDraft), isA<AuthCancelled>());
    });

    test('an unreachable backend is reported as a network problem', () async {
      final f = AuthFixture();
      f.api.forcedLookup = const ProfileUnreachable('down');
      final result = await f.repository.signUpWithGoogle(childDraft) as AuthFailed;
      expect(result.reason, AuthFailureReason.network);
    });
  });
}
