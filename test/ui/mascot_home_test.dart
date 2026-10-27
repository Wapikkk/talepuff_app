import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/core/mascots.dart';
import 'package:talepuff_app/data/models/child_profile.dart';
import 'package:talepuff_app/data/services/auth_gateway.dart';
import 'package:talepuff_app/data/services/auth_service.dart';
import 'package:talepuff_app/ui/view_models/navbar_view_model.dart';
import 'package:talepuff_app/ui/view_models/parents/child_info_view_model.dart';
import 'package:talepuff_app/ui/view_models/parents/parent_view_model.dart';
import 'package:talepuff_app/ui/view_models/parents/update_settings_view_model.dart';
import 'package:talepuff_app/ui/views/home/home_view.dart';
import 'package:talepuff_app/ui/views/settings/update_mascot_view.dart';
import 'package:talepuff_app/ui/widgets/home/mascot.dart';
import 'package:talepuff_app/ui/widgets/settings/account_settings.dart';

import '../support/fakes.dart';
import 'package:talepuff_app/l10n/l10n_labels.dart';
import '../support/l10n.dart';

/// Animasi baru mulai pada frame berikutnya, jadi dua pump: mulai, lalu selesai.
Future<void> settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

/// Layar ukuran ponsel (1080x2400 px pada 3x = 360x800 dp, seperti perangkat uji), bukan 800x600 bawaan.
void phoneTest(String description, Future<void> Function(WidgetTester tester) body) {
  testWidgets(description, (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await body(tester);
  });
}

String? assetOf(WidgetTester tester, Finder image) => ((tester.widget<Image>(image).image) as AssetImage).assetName;

void main() {
  group('Mascot widget', () {
    phoneTest('shows the image of the chosen mascot', (tester) async {
      for (final mascot in Mascots.all) {
        await tester.pumpWidget(MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: testLocale, home: Scaffold(body: Mascot(mascotId: mascot.id))));
        expect(assetOf(tester, find.byType(Image)), mascot.asset, reason: mascot.id);
      }
    });

    phoneTest('an unknown id shows the default mascot', (tester) async {
      await tester.pumpWidget(const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: testLocale, home: Scaffold(body: Mascot(mascotId: 'Naga'))));
      expect(assetOf(tester, find.byType(Image)), Mascots.all.first.asset);
    });
  });

  group('Mascot setting screen', () {
    Widget app(AccountFixture account, ChildInfoViewModel childInfo, ParentViewModel parent) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: childInfo),
          ChangeNotifierProvider.value(value: parent),
          ChangeNotifierProvider(create: (_) => UpdateSettingsViewModel(repository: account.repository)),
        ],
        child: MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: testLocale, 
          home: Builder(
            builder: (home) => Scaffold(
              body: ElevatedButton(
                child: const Text('open'),
                onPressed: () => Navigator.of(home).push(MaterialPageRoute<void>(builder: (_) => const UpdateMascotView())),
              ),
            ),
          ),
        ),
      );
    }

    (AccountFixture, ChildInfoViewModel, ParentViewModel) setUpAll() {
      final account = AccountFixture();
      final childInfo = ChildInfoViewModel(repository: AuthFixture().repository)
        ..applyProfile(const ChildProfile(id: 7, name: 'Aira', mascotId: 'Harimau'));
      final parent = ParentViewModel(photos: fakePhotos())..setInitiateData('7', null, 'Aira');
      return (account, childInfo, parent);
    }

    phoneTest('lists every mascot', (tester) async {
      final (account, childInfo, parent) = setUpAll();
      await tester.pumpWidget(app(account, childInfo, parent));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      for (final mascot in Mascots.all) {
        expect(find.text(lookupAppLocalizations(testLocale).mascotLabel(mascot.id)), findsOneWidget, reason: mascot.id);
      }
    });

    phoneTest('choosing another mascot saves it, updates the app and confirms with a banner', (tester) async {
      final (account, childInfo, parent) = setUpAll();
      await tester.pumpWidget(app(account, childInfo, parent));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Javan Rhino'));
      await tester.pump();
      await tester.tap(find.text('Update Mascot'));
      await settle(tester);

      expect(account.api.mascots, ['7:Badak']);
      expect(childInfo.mascotId, 'Badak', reason: 'Home shows it straight away');
      expect(find.text('Mascot updated!'), findsOneWidget);
      expect(find.text('open'), findsOneWidget, reason: 'went back to the previous screen');

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    phoneTest('the Update button stays disabled until a different mascot is chosen (no silent "success")', (tester) async {
      final (account, childInfo, parent) = setUpAll();
      await tester.pumpWidget(app(account, childInfo, parent));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      ElevatedButton button() => tester.widget<ElevatedButton>(find.byType(ElevatedButton));

      expect(button().onPressed, isNull, reason: 'the current mascot is preselected');

      await tester.tap(find.text('Orangutan'));
      await tester.pump();
      expect(button().onPressed, isNotNull);

      await tester.tap(find.text('Sumatran Tiger'));
      await tester.pump();
      expect(button().onPressed, isNull, reason: 'back to the current one: nothing to save');
      expect(account.api.mascots, isEmpty);
    });

    phoneTest('a failure shows the red message, keeps the old mascot and stays on the screen', (tester) async {
      final (account, childInfo, parent) = setUpAll();
      account.api.mascotError = const ProfileApiException('down', statusCode: 500);
      await tester.pumpWidget(app(account, childInfo, parent));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Orangutan'));
      await tester.pump();
      await tester.tap(find.text('Update Mascot'));
      await settle(tester);

      expect(find.textContaining("Can't reach the server"), findsOneWidget);
      expect(childInfo.mascotId, 'Harimau');
      expect(find.text('Update Mascot'), findsOneWidget, reason: 'still on the screen');

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });
  });

  group('Settings list', () {
    Future<void> show(WidgetTester tester, {required bool hasPassword}) {
      return tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => UpdateSettingsViewModel(repository: AccountFixture(hasPassword: hasPassword).repository),
          child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: testLocale, home: Scaffold(body: AccountSettings())),
        ),
      );
    }

    phoneTest('every account, including Google ones, can change the mascot', (tester) async {
      await show(tester, hasPassword: true);
      expect(find.text('Mascot'), findsOneWidget);

      await show(tester, hasPassword: false);
      expect(find.text('Mascot'), findsOneWidget);
    });
  });

  group('Home screen', () {
    Future<(ChildInfoViewModel, NavbarViewModel)> pumpHome(WidgetTester tester, {String mascot = 'Harimau'}) async {
      final fixture = AuthFixture(signedInUser: const AuthUser('uid-1', 'parent@example.com'));
      fixture.api.store['uid-1'] = ChildProfile(id: 7, name: 'Aira', mascotId: mascot);
      final childInfo = ChildInfoViewModel(repository: fixture.repository)
        ..applyProfile(ChildProfile(id: 7, name: 'Aira', mascotId: mascot));
      final navbar = NavbarViewModel();

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: childInfo),
          ChangeNotifierProvider.value(value: navbar),
        ],
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: testLocale, home: HomeView()),
      ));
      await tester.pump();
      return (childInfo, navbar);
    }

    phoneTest('greets the child by name straight away and shows the chosen mascot', (tester) async {
      await pumpHome(tester, mascot: 'Badak');

      expect(find.textContaining('Aira'), findsOneWidget);
      expect(find.textContaining('Friend'), findsNothing);
      expect(assetOf(tester, find.descendant(of: find.byType(Mascot), matching: find.byType(Image))), Mascots.byId('Badak').asset);
    });

    phoneTest('the search bar is hidden until the Story page can feed it', (tester) async {
      await pumpHome(tester);
      expect(find.text('Search your story'), findsNothing);
      expect(find.byIcon(Icons.search), findsNothing);
    });

    phoneTest('Play Last Story says it is coming soon instead of doing nothing', (tester) async {
      await pumpHome(tester);

      await tester.tap(find.text('Play Last Story'));
      await settle(tester);

      expect(find.text('Play Last Story is coming soon!'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    phoneTest('Create New Story switches to the Create tab', (tester) async {
      final (_, navbar) = await pumpHome(tester);

      await tester.tap(find.text('Create New Story'));
      await tester.pump();

      expect(navbar.currentIndex, 2);
    });
  });
}
