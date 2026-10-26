import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talepuff_app/ui/widgets/bottom_navbar.dart';

void main() {
  Future<void> open(WidgetTester tester, ValueNotifier<int> index) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder<int>(
          valueListenable: index,
          builder: (context, value, _) => Scaffold(
            body: const SizedBox.expand(),
            bottomNavigationBar: BottomNavbar(
              currentIndex: value,
              onTap: (i) => index.value = i,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder indicator() => find.byKey(const Key('nav-indicator'));

  testWidgets('shows the four tabs and reports the one that was tapped', (
    tester,
  ) async {
    final index = ValueNotifier(0);
    await open(tester, index);

    for (final label in ['Home', 'Story', 'Create', 'Parents']) {
      expect(find.text(label), findsOneWidget);
    }

    await tester.tap(find.byKey(const Key('nav-create')));
    await tester.pump();
    expect(index.value, 2);
  });

  testWidgets(
    'no widget that draws a ripple is used, so a tap leaves nothing behind',
    (tester) async {
      final index = ValueNotifier(0);
      await open(tester, index);

      for (final type in [InkWell, InkResponse, BottomNavigationBar]) {
        expect(
          find.descendant(
            of: find.byType(BottomNavbar),
            matching: find.byType(type),
          ),
          findsNothing,
          reason: '$type',
        );
      }
      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const Key('nav-story'))),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.up();
      await tester.pump(const Duration(milliseconds: 500));
      expect(index.value, 1);
    },
  );

  testWidgets(
    'the line slides to the tapped tab instead of disappearing and reappearing',
    (tester) async {
      final index = ValueNotifier(0);
      await open(tester, index);
      final start = tester.getCenter(indicator()).dx;

      await tester.tap(find.byKey(const Key('nav-parents')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final midway = tester.getCenter(indicator()).dx;
      expect(
        tester.getSize(indicator()).width,
        30,
        reason: 'it stays visible while moving',
      );
      await tester.pump(const Duration(milliseconds: 600));
      final end = tester.getCenter(indicator()).dx;

      expect(midway, greaterThan(start));
      expect(midway, lessThan(end));
      expect(
        end,
        closeTo(tester.getCenter(find.byKey(const Key('nav-parents'))).dx, 0.5),
        reason: 'it ends centred on the tab',
      );
    },
  );

  testWidgets(
    'the line always ends up centred on the selected tab, going either way',
    (tester) async {
      final index = ValueNotifier(0);
      await open(tester, index);

      for (final target in [3, 1, 2, 0]) {
        index.value = target;
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));
        final tab = ['home', 'story', 'create', 'parents'][target];
        expect(
          tester.getCenter(indicator()).dx,
          closeTo(tester.getCenter(find.byKey(Key('nav-$tab'))).dx, 0.5),
          reason: tab,
        );
      }
    },
  );
}
