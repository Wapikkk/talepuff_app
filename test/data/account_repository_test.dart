import 'package:flutter_test/flutter_test.dart';
import 'package:talepuff_app/data/models/account_result.dart';
import 'package:talepuff_app/data/models/app_message.dart';
import 'package:talepuff_app/data/services/auth_gateway.dart';
import 'package:talepuff_app/data/services/auth_service.dart';

import '../support/fakes.dart';

AppMessage failureOf(AccountResult result) => (result as AccountFailure).message;

void main() {
  group('updateChildName', () {
    test('saves the trimmed name and reports it back', () async {
      final f = AccountFixture();
      final result = await f.repository.updateChildName(childId: 7, name: '  Aira  ');

      expect(result, isA<AccountSuccess>());
      expect((result as AccountSuccess).value, 'Aira');
      expect(f.api.renamed, ['7:Aira']);
    });

    test('rejects names the story generator would silently replace with "Pip"', () async {
      final f = AccountFixture();
      for (final name in ['', '   ', 'Aira 2', 'Aira!', '123', 'A' * 31]) {
        expect(await f.repository.updateChildName(childId: 7, name: name), isA<AccountFailure>(), reason: name);
      }
      expect(f.api.renamed, isEmpty, reason: 'an invalid name must never reach the backend');
    });

    test('accepts spaces, apostrophes and hyphens', () async {
      final f = AccountFixture();
      for (final name in ["Mary-Ann", "D'Arcy", 'Anna Maria']) {
        expect(await f.repository.updateChildName(childId: 7, name: name), isA<AccountSuccess>(), reason: name);
      }
    });

    test('the server rejecting the name (400) or not finding the child (404) gets its own message', () async {
      final rejected = AccountFixture();
      rejected.api.renameError = const ProfileApiException('bad', statusCode: 400);
      expect(
        failureOf(await rejected.repository.updateChildName(childId: 7, name: 'Aira')),
        AppMessage.childNameRejected,
      );

      final missing = AccountFixture();
      missing.api.renameError = const ProfileApiException('gone', statusCode: 404);
      expect(
        failureOf(await missing.repository.updateChildName(childId: 7, name: 'Aira')),
        AppMessage.childProfileNotFound,
      );
    });

    test('a rejected session (401) asks the user to login again', () async {
      final f = AccountFixture();
      f.api.renameError = const ProfileApiException('unauthorized', statusCode: 401);
      expect(failureOf(await f.repository.updateChildName(childId: 7, name: 'Aira')), AppMessage.reloginRequired);
    });

    test('a backend failure is shown as a connection problem', () async {
      final f = AccountFixture();
      f.api.renameError = const ProfileApiException('down');
      final result = await f.repository.updateChildName(childId: 7, name: 'Aira');
      expect(failureOf(result), AppMessage.serverUnreachable);
    });
  });

  group('changePassword', () {
    Future<AccountResult> change(AccountFixture f, {String current = 'oldpass1', String next = 'newpass1', String? confirm}) {
      return f.repository.changePassword(currentPassword: current, newPassword: next, confirmPassword: confirm ?? next);
    }

    test('success calls Firebase once with the trimmed passwords', () async {
      final f = AccountFixture();
      final result = await change(f, current: ' oldpass1 ', next: ' newpass1 ');

      expect(result, isA<AccountSuccess>());
      expect(f.gateway.calls, ['changePassword:oldpass1->newpass1']);
    });

    test('input problems are caught before Firebase is contacted', () async {
      final f = AccountFixture();
      final cases = {
        AppMessage.currentPasswordRequired: change(f, current: ''),
        AppMessage.passwordRules: change(f, next: 'short1'),
        AppMessage.passwordsMismatch: change(f, confirm: 'different1'),
        AppMessage.passwordSameAsCurrent: change(f, current: 'samepass1', next: 'samepass1'),
      };
      for (final entry in cases.entries) {
        expect(failureOf(await entry.value), entry.key);
      }
      expect(f.gateway.calls, isEmpty);
    });

    test('a wrong current password is reported as such', () async {
      final f = AccountFixture();
      f.gateway.failure = const AuthFailure(AuthGatewayError.invalidCredentials);
      expect(failureOf(await change(f)), AppMessage.currentPasswordIncorrect);
    });

    test('firebase errors map to specific messages', () async {
      final expectations = {
        AuthGatewayError.weakPassword: AppMessage.weakPassword,
        AuthGatewayError.requiresRecentLogin: AppMessage.reloginRequired,
        AuthGatewayError.sessionExpired: AppMessage.reloginRequired,
        AuthGatewayError.tooManyRequests: AppMessage.tooManyRequests,
        AuthGatewayError.network: AppMessage.noConnection,
        AuthGatewayError.unknown: AppMessage.genericError,
      };
      for (final entry in expectations.entries) {
        final f = AccountFixture();
        f.gateway.failure = AuthFailure(entry.key);
        expect(failureOf(await change(f)), entry.value, reason: '${entry.key}');
      }
    });

    test('a Google-only account cannot change its password', () async {
      final f = AccountFixture(hasPassword: false);
      expect(failureOf(await change(f)), AppMessage.managedByGoogle);
      expect(f.gateway.calls, isEmpty);
    });
  });

  group('requestEmailChange', () {
    test('sends a verification link and explains that the email changes after opening it', () async {
      final f = AccountFixture();
      final result = await f.repository.requestEmailChange(newEmail: ' new@example.com ', currentPassword: 'oldpass1');

      expect(result, isA<AccountSuccess>());
      expect((result as AccountSuccess).message, AppMessage.verificationSent);
      expect(result.value, 'new@example.com');
      expect(f.gateway.calls, ['requestEmailChange:new@example.com']);
      expect(f.api.renamed, isEmpty);
    });

    test('rejects a malformed address, the current address, and a missing password', () async {
      final f = AccountFixture(email: 'parent@example.com');

      expect(
        failureOf(await f.repository.requestEmailChange(newEmail: 'nope', currentPassword: 'x')),
        AppMessage.emailInvalid,
      );
      expect(
        failureOf(await f.repository.requestEmailChange(newEmail: 'PARENT@example.com', currentPassword: 'x')),
        AppMessage.sameEmail,
      );
      expect(
        failureOf(await f.repository.requestEmailChange(newEmail: 'new@example.com', currentPassword: '')),
        AppMessage.currentPasswordRequired,
      );
      expect(f.gateway.calls, isEmpty);
    });

    test('firebase errors map to specific messages', () async {
      final expectations = {
        AuthGatewayError.invalidCredentials: AppMessage.currentPasswordIncorrect,
        AuthGatewayError.emailInUse: AppMessage.emailInUse,
        AuthGatewayError.invalidEmail: AppMessage.emailInvalid,
        AuthGatewayError.requiresRecentLogin: AppMessage.reloginRequired,
      };
      for (final entry in expectations.entries) {
        final f = AccountFixture();
        f.gateway.failure = AuthFailure(entry.key);
        final result = await f.repository.requestEmailChange(newEmail: 'new@example.com', currentPassword: 'oldpass1');
        expect(failureOf(result), entry.value, reason: '${entry.key}');
      }
    });

    test('a Google-only account cannot change its email', () async {
      final f = AccountFixture(hasPassword: false);
      final result = await f.repository.requestEmailChange(newEmail: 'new@example.com', currentPassword: 'x');
      expect(failureOf(result), AppMessage.managedByGoogle);
      expect(f.gateway.calls, isEmpty);
    });
  });

  test('canManageCredentials follows the sign-in provider', () {
    expect(AccountFixture(hasPassword: true).repository.canManageCredentials, isTrue);
    expect(AccountFixture(hasPassword: false).repository.canManageCredentials, isFalse);
  });
}
