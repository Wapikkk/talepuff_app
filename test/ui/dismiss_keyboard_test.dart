import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/data/services/server_check_service.dart';
import 'package:talepuff_app/ui/view_models/auth/signup_view_model.dart';
import 'package:talepuff_app/ui/view_models/parents/child_info_view_model.dart';
import 'package:talepuff_app/ui/view_models/parents/parent_view_model.dart';
import 'package:talepuff_app/ui/view_models/parents/update_settings_view_model.dart';
import 'package:talepuff_app/ui/views/settings/server_address_view.dart';
import 'package:talepuff_app/ui/views/settings/update_child_name_view.dart';
import 'package:talepuff_app/ui/views/settings/update_email_view.dart';
import 'package:talepuff_app/ui/views/settings/update_password_view.dart';
import 'package:talepuff_app/ui/views/sign_up/signup_view.dart';
import 'package:talepuff_app/ui/widgets/shared/dismiss_keyboard.dart';

import '../support/fakes.dart';
import '../support/l10n.dart';

class _IdleChecker implements ServerChecker {
  @override
  Future<ServerCheckResult> check(String baseUrl) async =>
      const ServerReachable();
}

Widget screen(Widget home) {
  final account = AccountFixture();
  final auth = AuthFixture();
  final parent = ParentViewModel(photos: fakePhotos())
    ..setInitiateData('7', null, 'Aira');
  final childInfo = ChildInfoViewModel(repository: auth.repository);

  return MultiProvider(
    providers: [
      ChangeNotifierProvider.value(value: parent),
      ChangeNotifierProvider.value(value: childInfo),
      ChangeNotifierProvider(
        create: (_) => UpdateSettingsViewModel(repository: account.repository),
      ),
      ChangeNotifierProvider(
        create: (_) => SignUpViewModel(
          repository: auth.repository,
          childInfoViewModel: childInfo,
        ),
      ),
      Provider<ServerChecker>.value(value: _IdleChecker()),
    ],
    child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: testLocale, home: home),
  );
}

void main() {
  setUpAll(() => dotenv.loadFromString(envString: 'API_BASE_URL=http://10.0.0.9:8080'));

  final screens = <String, Widget>{
    "Child's Name": const UpdateChildNameView(),
    'Email': const UpdateEmailView(),
    'Update Password': const UpdatePasswordView(),
    'Server Address': const ServerAddressView(),
    'Sign Up': const SignUpView(),
  };

  for (final entry in screens.entries) {
    testWidgets('${entry.key}: tapping outside the field closes the keyboard', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exceptionAsString().contains('overflowed')) return;
        originalOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalOnError);

      await tester.pumpWidget(screen(entry.value));
      await tester.pump();

      final field = find.byType(TextField).first;
      await tester.tap(field);
      await tester.pump();
      EditableTextState editable() => tester.state<EditableTextState>(
        find.descendant(of: field, matching: find.byType(EditableText)),
      );
      expect(
        editable().widget.focusNode.hasFocus,
        isTrue,
        reason: 'tapping the field opens the keyboard',
      );

      await tester.tapAt(const Offset(180, 780));
      await tester.pump();

      expect(
        editable().widget.focusNode.hasFocus,
        isFalse,
        reason: 'tapping empty space closes it',
      );
    });
  }

  testWidgets(
    'a tap on a button still works and does not get swallowed by the keyboard dismissal',
    (tester) async {
      var pressed = 0;
      await tester.pumpWidget(
        MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: testLocale, 
          home: Scaffold(
            body: DismissKeyboard(
              child: Center(
                child: TextButton(
                  onPressed: () => pressed++,
                  child: const Text('go'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('go'));

      expect(pressed, 1);
    },
  );
}
