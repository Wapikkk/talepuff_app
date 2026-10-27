import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/data/repositories/auth_repository.dart';
import 'package:talepuff_app/data/models/child_profile.dart';
import 'package:talepuff_app/data/services/auth_gateway.dart';
import 'package:talepuff_app/data/services/auth_service.dart';
import 'package:talepuff_app/ui/view_models/auth/login_view_model.dart';
import 'package:talepuff_app/ui/view_models/parents/child_info_view_model.dart';
import 'package:talepuff_app/ui/view_models/navbar_view_model.dart';
import 'package:talepuff_app/ui/view_models/parents/parent_view_model.dart';
import 'package:talepuff_app/ui/view_models/startup_view_model.dart';
import 'package:talepuff_app/ui/views/child_info/child_info_args.dart';
import 'package:talepuff_app/ui/views/startup/startup_view.dart';

import '../support/fakes.dart';
import '../support/l10n.dart';

/// Aplikasi mini dengan layar tujuan berupa teks penanda, supaya yang diuji hanya alur pembuka.
Widget buildApp(AuthFixture f, {NavbarViewModel? navbar}) {
  return MultiProvider(
    providers: [
      Provider<AuthRepository>.value(value: f.repository),
      ChangeNotifierProvider(create: (_) => LoginViewModel(repository: f.repository)),
      ChangeNotifierProvider(create: (_) => ParentViewModel(photos: fakePhotos())),
      ChangeNotifierProvider.value(value: navbar ?? NavbarViewModel()),
      ChangeNotifierProvider(create: (_) => StartupViewModel(repository: f.repository)),
      ChangeNotifierProvider(create: (_) => ChildInfoViewModel(repository: f.repository)),
    ],
    child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: testLocale, 
      initialRoute: '/',
      routes: {
        '/': (_) => const StartupView(),
        '/landing': (_) => const Text('LANDING', textDirection: TextDirection.ltr),
        '/main_nav': (_) => const Text('MAIN', textDirection: TextDirection.ltr),
        '/server_address': (_) => const Text('SERVER', textDirection: TextDirection.ltr),
        '/child_info': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          final complete = args is ChildInfoArgs && args.completeProfile;
          return Text('CHILD_INFO complete=$complete', textDirection: TextDirection.ltr);
        },
      },
    ),
  );
}

void main() {
  testWidgets('no saved session goes to the landing page', (tester) async {
    final f = AuthFixture();

    await tester.pumpWidget(buildApp(f));
    await tester.pumpAndSettle();

    expect(find.text('LANDING'), findsOneWidget);
  });

  testWidgets('entering the app always starts on the Home tab, not the tab used before logout', (tester) async {
    final f = AuthFixture(signedInUser: const AuthUser('uid-1', 'parent@example.com'));
    f.seedProfile(id: 7, name: 'Aira');
    final navbar = NavbarViewModel()..changeIndex(3); // Parent tab, where the Logout button lives

    await tester.pumpWidget(buildApp(f, navbar: navbar));
    await tester.pumpAndSettle();

    expect(find.text('MAIN'), findsOneWidget);
    expect(navbar.currentIndex, 0);
  });

  testWidgets('the child data is ready from the login data itself (no "Friend" flash, no extra request)', (tester) async {
    final f = AuthFixture(signedInUser: const AuthUser('uid-1', 'parent@example.com'));
    f.api.store['uid-1'] = const ChildProfile(id: 7, name: 'Aira', age: 3, interests: ['Space'], mascotId: 'Badak');

    await tester.pumpWidget(buildApp(f));
    await tester.pumpAndSettle();

    final childInfo = tester.element(find.text('MAIN')).read<ChildInfoViewModel>();
    expect(childInfo.childName, 'Aira');
    expect(childInfo.age, '3');
    expect(childInfo.selectedInterests, ['Space']);
    expect(childInfo.mascotId, 'Badak');
    expect(f.api.fetchCalls, 1, reason: 'only the lookup done while restoring the session');
  });

  testWidgets('a saved session with a profile skips login and prepares the session data', (tester) async {
    final f = AuthFixture(signedInUser: const AuthUser('uid-1', 'parent@example.com'));
    f.seedProfile(id: 7, name: 'Aira');

    await tester.pumpWidget(buildApp(f));
    await tester.pumpAndSettle();

    expect(find.text('MAIN'), findsOneWidget);
    final context = tester.element(find.text('MAIN'));
    expect(context.read<LoginViewModel>().currentChildId, '7');
    expect(context.read<ParentViewModel>().currentChildId, '7');
    expect(context.read<ParentViewModel>().currentChildName, 'Aira');
    expect(f.session.activeChildId, 7, reason: 'create-story reads this key');
    expect(Navigator.of(context).canPop(), isFalse, reason: 'back must not return to startup/login');
  });

  testWidgets('a saved session without a profile opens the complete-profile form', (tester) async {
    final f = AuthFixture(signedInUser: const AuthUser('uid-1', null));

    await tester.pumpWidget(buildApp(f));
    await tester.pumpAndSettle();

    expect(find.text('CHILD_INFO complete=true'), findsOneWidget);
  });

  testWidgets('an unreachable server shows a message and retry works once the server is back', (tester) async {
    final f = AuthFixture(signedInUser: const AuthUser('uid-1', null));
    f.seedProfile();
    f.api.forcedLookup = const ProfileUnreachable('down');

    await tester.pumpWidget(buildApp(f));
    await tester.pumpAndSettle();

    expect(find.textContaining("Can't reach the server"), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);

    f.api.forcedLookup = null; // server menyala kembali
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.text('MAIN'), findsOneWidget);
  });

  testWidgets('a network failure offers to change the server address, and coming back retries', (tester) async {
    final f = AuthFixture(signedInUser: const AuthUser('uid-1', null));
    f.seedProfile();
    f.api.forcedLookup = const ProfileUnreachable('down');

    await tester.pumpWidget(buildApp(f));
    await tester.pumpAndSettle();
    final callsBefore = f.api.fetchCalls;

    await tester.tap(find.byKey(const Key('change-server')));
    await tester.pumpAndSettle();
    expect(find.text('SERVER'), findsOneWidget);

    f.api.forcedLookup = null;
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pop();
    await tester.pumpAndSettle();

    expect(f.api.fetchCalls, greaterThan(callsBefore), reason: 'it asks the server again with the new address');
    expect(find.text('MAIN'), findsOneWidget);
  });

  testWidgets('a failure that is not about the network does not offer to change the address', (tester) async {
    final f = AuthFixture(signedInUser: const AuthUser('uid-1', null));
    f.api.forcedLookup = const ProfileRejected();

    await tester.pumpWidget(buildApp(f));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('change-server')), findsNothing);
  });

  testWidgets('"Use a different account" signs out and goes to the landing page', (tester) async {
    final f = AuthFixture(signedInUser: const AuthUser('uid-1', null));
    f.api.forcedLookup = const ProfileUnreachable('down');

    await tester.pumpWidget(buildApp(f));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use a different account'));
    await tester.pumpAndSettle();

    expect(find.text('LANDING'), findsOneWidget);
    expect(f.gateway.signOutCalls, 1);
  });
}
