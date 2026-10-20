import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/data/services/auth_gateway.dart';
import 'package:talepuff_app/ui/view_models/parents/child_info_view_model.dart';
import 'package:talepuff_app/ui/view_models/parents/parent_view_model.dart';
import 'package:talepuff_app/ui/view_models/parents/update_settings_view_model.dart';
import 'package:talepuff_app/ui/views/settings/update_child_name_view.dart';
import 'package:talepuff_app/ui/widgets/shared/top_banner.dart';

import '../support/fakes.dart';

Widget bannerApp({required void Function(BuildContext) onOpen}) {
  return MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(onPressed: () => onOpen(context), child: const Text('go')),
        ),
      ),
    ),
  );
}

/// Animasi baru mulai pada frame berikutnya setelah ketukan, jadi dua pump: mulai, lalu selesai.
Future<void> letAnimationFinish(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

void main() {
  group('TopBanner', () {
    testWidgets('slides in with the message and disappears by itself', (tester) async {
      await tester.pumpWidget(bannerApp(
        onOpen: (context) => TopBanner.show(TopBanner.overlayOf(context), 'Saved!', duration: const Duration(seconds: 2)),
      ));

      await tester.tap(find.text('go'));
      await letAnimationFinish(tester);
      expect(find.text('Saved!'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Saved!'), findsNothing);
    });

    testWidgets('appears at the TOP of the screen', (tester) async {
      await tester.pumpWidget(bannerApp(
        onOpen: (context) => TopBanner.show(TopBanner.overlayOf(context), 'Saved!'),
      ));

      await tester.tap(find.text('go'));
      await letAnimationFinish(tester);

      final top = tester.getTopLeft(find.text('Saved!')).dy;
      final screenHeight = tester.view.physicalSize.height / tester.view.devicePixelRatio;
      expect(top, greaterThanOrEqualTo(0), reason: 'fully slid into view, not still above the screen');
      expect(top, lessThan(screenHeight / 4), reason: 'near the top edge, not the bottom like a SnackBar');

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('survives the screen that showed it being closed', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Builder(
          builder: (home) => Scaffold(
            body: ElevatedButton(
              child: const Text('open'),
              onPressed: () => Navigator.of(home).push(MaterialPageRoute<void>(
                builder: (page) => Scaffold(
                  body: ElevatedButton(
                    child: const Text('save'),
                    onPressed: () {
                      final overlay = TopBanner.overlayOf(page);
                      TopBanner.show(overlay, 'Saved!');
                      Navigator.of(page).pop();
                    },
                  ),
                ),
              )),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('save'));
      await letAnimationFinish(tester);

      expect(find.text('save'), findsNothing, reason: 'the screen is closed');
      expect(find.text('Saved!'), findsOneWidget, reason: 'the banner stays on the previous screen');

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('a new banner replaces the old one instead of stacking', (tester) async {
      var count = 0;
      await tester.pumpWidget(bannerApp(
        onOpen: (context) {
          count++;
          TopBanner.show(TopBanner.overlayOf(context), 'Message $count');
        },
      ));

      await tester.tap(find.text('go'));
      await letAnimationFinish(tester);
      await tester.tap(find.text('go'));
      await letAnimationFinish(tester);

      expect(find.text('Message 1'), findsNothing);
      expect(find.text('Message 2'), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('tapping the banner dismisses it early', (tester) async {
      await tester.pumpWidget(bannerApp(
        onOpen: (context) => TopBanner.show(TopBanner.overlayOf(context), 'Saved!', duration: const Duration(seconds: 30)),
      ));

      await tester.tap(find.text('go'));
      await letAnimationFinish(tester);
      await tester.tap(find.text('Saved!'));
      await letAnimationFinish(tester);

      expect(find.text('Saved!'), findsNothing);
    });
  });

  group('ChildInfoViewModel.applySavedName', () {
    test('replaces the shown name and overrides a stale registration draft', () {
      final vm = ChildInfoViewModel(repository: AuthFixture().repository)..name = 'Aira';
      expect(vm.childName, 'Aira');

      var notified = 0;
      vm.addListener(() => notified++);
      vm.applySavedName('  Bimo  ');

      expect(vm.childName, 'Bimo', reason: 'the old draft must not hide the saved name');
      expect(notified, 1);
    });
  });

  group('renaming the child from Settings', () {
    testWidgets('the Parent/Home name changes immediately and a banner confirms it', (tester) async {
      final account = AccountFixture();
      final parent = ParentViewModel(photos: fakePhotos())..setInitiateData('7', null, 'Aira');
      final childInfo = ChildInfoViewModel(repository: AuthFixture(signedInUser: const AuthUser('uid-1', null)).repository)
        ..applySavedName('Aira');

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: parent),
          ChangeNotifierProvider.value(value: childInfo),
          ChangeNotifierProvider(create: (_) => UpdateSettingsViewModel(repository: account.repository)),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (home) => Scaffold(
              body: ElevatedButton(
                child: const Text('settings'),
                onPressed: () => Navigator.of(home).push(
                  MaterialPageRoute<void>(builder: (_) => const UpdateChildNameView()),
                ),
              ),
            ),
          ),
        ),
      ));

      await tester.tap(find.text('settings'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Bimo');
      await tester.tap(find.text('Update Name'));
      await letAnimationFinish(tester);

      expect(childInfo.childName, 'Bimo', reason: 'Parent page and Home greeting read this');
      expect(parent.currentChildName, 'Bimo');
      expect(find.text('Name updated successfully!'), findsOneWidget);
      expect(find.text('settings'), findsOneWidget, reason: 'went back to the previous screen');
      expect(account.api.renamed, ['7:Bimo']);

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });

    testWidgets('a rejected name shows the red message and changes nothing', (tester) async {
      final account = AccountFixture();
      final parent = ParentViewModel(photos: fakePhotos())..setInitiateData('7', null, 'Aira');
      final childInfo = ChildInfoViewModel(repository: AuthFixture().repository)..applySavedName('Aira');

      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: parent),
          ChangeNotifierProvider.value(value: childInfo),
          ChangeNotifierProvider(create: (_) => UpdateSettingsViewModel(repository: account.repository)),
        ],
        child: const MaterialApp(home: UpdateChildNameView()),
      ));

      await tester.enterText(find.byType(TextField), 'Aira 2');
      await tester.tap(find.text('Update Name'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.textContaining('letters'), findsOneWidget);
      expect(find.text('Name updated successfully!'), findsNothing);
      expect(childInfo.childName, 'Aira');

      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
    });
  });
}
