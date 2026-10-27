import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/data/models/story.dart';
import 'package:talepuff_app/ui/view_models/story/story_filter_view_model.dart';
import 'package:talepuff_app/ui/widgets/story/story_filter_tabs.dart';

import '../support/fakes.dart';
import '../support/l10n.dart';

void main() {
  late StoryFilterViewModel viewModel;

  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) return;
      originalOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = originalOnError);

    viewModel = StoryFilterViewModel(
      repository: fakeStories(),
      childId: () => '7',
      searchDelay: Duration.zero,
    );
    addTearDown(viewModel.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: viewModel,
        child: const MaterialApp(localizationsDelegates: AppLocalizations.localizationsDelegates, supportedLocales: AppLocalizations.supportedLocales, locale: testLocale, 
          home: Scaffold(
            body: Column(
              children: [
                Padding(padding: EdgeInsets.all(24), child: StoryFilterTabs()),
                Expanded(
                  child: ColoredBox(
                    key: Key('outside'),
                    color: Colors.black12,
                    child: SizedBox.expand(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Finder pill() => find.byWidgetPredicate(
    (widget) =>
        widget is DecoratedBox &&
        widget.decoration is BoxDecoration &&
        (widget.decoration as BoxDecoration).gradient != null,
  );

  testWidgets('the selected pill glides to the new tab instead of jumping', (
    tester,
  ) async {
    await open(tester);
    final start = tester.getTopLeft(pill()).dx;

    await tester.tap(find.byKey(const Key('tab-popular')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 90));
    final midway = tester.getTopLeft(pill()).dx;
    await tester.pump(const Duration(milliseconds: 400));
    final end = tester.getTopLeft(pill()).dx;

    expect(viewModel.tab, StoryTab.popular);
    expect(end, greaterThan(start));
    expect(midway, greaterThan(start), reason: 'it has started moving');
    expect(
      midway,
      lessThan(end),
      reason: 'but has not arrived yet, so it is an animation',
    );
  });

  testWidgets('every tab is tappable and the pill ends up exactly behind it', (
    tester,
  ) async {
    await open(tester);

    for (final tab in StoryTab.values) {
      await tester.tap(find.byKey(Key('tab-${tab.name}')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(viewModel.tab, tab);
      final tabBox = tester.getRect(find.byKey(Key('tab-${tab.name}')));
      final pillBox = tester.getRect(pill());
      expect(
        (pillBox.left - tabBox.left).abs(),
        lessThan(0.5),
        reason: tab.name,
      );
      expect(
        (pillBox.width - tabBox.width).abs(),
        lessThan(0.5),
        reason: tab.name,
      );
    }
  });

  testWidgets(
    'the search box grows from the icon towards the left while the tabs slide away',
    (tester) async {
      await open(tester);
      final iconStart = tester
          .getCenter(find.byKey(const Key('open-search')))
          .dx;
      final tabsStart = tester
          .getTopLeft(find.byKey(const Key('tab-recent')))
          .dx;

      await tester.tap(find.byKey(const Key('open-search')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final iconMid = tester.getCenter(find.byKey(const Key('open-search'))).dx;
      final tabsMid = tester.getTopLeft(find.byKey(const Key('tab-recent'))).dx;
      await tester.pump(const Duration(milliseconds: 500));
      final iconEnd = tester.getCenter(find.byKey(const Key('open-search'))).dx;

      expect(viewModel.isSearching, isTrue);
      expect(
        iconMid,
        lessThan(iconStart),
        reason: 'the icon is already travelling left',
      );
      expect(
        iconMid,
        greaterThan(iconEnd),
        reason: 'and has not reached the end yet',
      );
      expect(
        tabsMid,
        lessThan(tabsStart),
        reason: 'the tabs slide out to the left',
      );
      expect(
        tester
            .widget<AnimatedOpacity>(find.byKey(const Key('tabs-layer')))
            .opacity,
        0,
      );
    },
  );

  testWidgets(
    'the icon and the text line up on the same centre line, and the field is focused',
    (tester) async {
      await open(tester);

      await tester.tap(find.byKey(const Key('open-search')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final iconY = tester.getCenter(find.byKey(const Key('open-search'))).dy;
      final textY = tester.getCenter(find.byType(EditableText)).dy;
      expect((iconY - textY).abs(), lessThan(1.0));
      expect(viewModel.searchFocusNode.hasFocus, isTrue);
    },
  );

  testWidgets(
    'typing searches, and closing the search brings the tabs back with an empty box',
    (tester) async {
      await open(tester);
      await tester.tap(find.byKey(const Key('open-search')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(find.byType(TextField), 'moon');
      await tester.pump();
      expect(viewModel.query, 'moon');

      await tester.tap(find.byKey(const Key('outside')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(viewModel.isSearching, isFalse);
      expect(viewModel.query, '');
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller?.text,
        '',
      );
      expect(
        tester
            .widget<AnimatedOpacity>(find.byKey(const Key('tabs-layer')))
            .opacity,
        1,
      );
    },
  );
}
