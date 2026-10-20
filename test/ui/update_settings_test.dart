import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/data/models/account_result.dart';
import 'package:talepuff_app/data/services/auth_gateway.dart';
import 'package:talepuff_app/ui/view_models/parents/update_settings_view_model.dart';
import 'package:talepuff_app/ui/widgets/settings/account_settings.dart';

import '../support/fakes.dart';

UpdateSettingsViewModel viewModelFor(AccountFixture f) => UpdateSettingsViewModel(repository: f.repository);

void main() {
  group('UpdateSettingsViewModel', () {
    test('a successful rename returns the result and leaves no error', () async {
      final f = AccountFixture();
      final vm = viewModelFor(f);

      final result = await vm.updateChildName(childId: '7', name: 'Aira');

      expect(result, isA<AccountSuccess>());
      expect(vm.errorMessage, isNull);
      expect(vm.isLoading, isFalse);
      expect(f.api.renamed, ['7:Aira']);
    });

    test('a failure is shown as the error message, not swallowed', () async {
      final vm = viewModelFor(AccountFixture());
      await vm.updateChildName(childId: '7', name: 'Aira 2');
      expect(vm.errorMessage, contains('letters'));
    });

    test('a missing child id is explained instead of doing nothing', () async {
      final f = AccountFixture();
      final vm = viewModelFor(f);

      await vm.updateChildName(childId: null, name: 'Aira');

      expect(vm.errorMessage, contains('not been loaded'));
      expect(f.api.renamed, isEmpty);
    });

    test('a wrong current password shows a clear message', () async {
      final f = AccountFixture();
      f.gateway.failure = const AuthFailure(AuthGatewayError.invalidCredentials);
      final vm = viewModelFor(f);

      await vm.changePassword(currentPassword: 'oldpass1', newPassword: 'newpass1', confirmPassword: 'newpass1');

      expect(vm.errorMessage, 'Current password is incorrect.');
    });

    test('a second tap while the first is running is ignored (no duplicate request)', () async {
      final f = AccountFixture();
      f.gateway.gate = Completer<void>();
      final vm = viewModelFor(f);

      final first = vm.changePassword(currentPassword: 'oldpass1', newPassword: 'newpass1', confirmPassword: 'newpass1');
      final second = await vm.changePassword(currentPassword: 'oldpass1', newPassword: 'newpass1', confirmPassword: 'newpass1');

      expect(second, isNull);
      expect(vm.isLoading, isTrue);

      f.gateway.gate!.complete();
      expect(await first, isA<AccountSuccess>());
      expect(vm.isLoading, isFalse);
      expect(f.gateway.calls, hasLength(1));
    });

    test('the error is cleared when a screen opens, and disappears by itself', () async {
      final vm = viewModelFor(AccountFixture());
      await vm.updateChildName(childId: '7', name: '');
      expect(vm.errorMessage, isNotNull);

      vm.clearError();
      expect(vm.errorMessage, isNull);
    });

    test('canManageCredentials mirrors the sign-in method', () {
      expect(viewModelFor(AccountFixture(hasPassword: true)).canManageCredentials, isTrue);
      expect(viewModelFor(AccountFixture(hasPassword: false)).canManageCredentials, isFalse);
    });
  });

  group('AccountSettings menu', () {
    Future<void> show(WidgetTester tester, AccountFixture f) {
      return tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => viewModelFor(f),
          child: const MaterialApp(home: Scaffold(body: AccountSettings())),
        ),
      );
    }

    testWidgets('an email+password account sees all three options', (tester) async {
      await show(tester, AccountFixture(hasPassword: true));

      expect(find.text("Child's Name"), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Update Password'), findsOneWidget);
    });

    testWidgets('a Google account only sees Child\'s Name', (tester) async {
      await show(tester, AccountFixture(hasPassword: false));

      expect(find.text("Child's Name"), findsOneWidget);
      expect(find.text('Email'), findsNothing);
      expect(find.text('Update Password'), findsNothing);
    });
  });
}
