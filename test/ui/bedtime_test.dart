import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:talepuff_app/data/models/totem.dart';
import 'package:talepuff_app/data/services/totem_service.dart';
import 'package:talepuff_app/ui/widgets/parent/bedtime_story.dart';

import '../support/fakes.dart';
import '../support/l10n.dart';

void main() {
  Widget app(FakeTotemApi api, {Locale locale = testLocale}) => ChangeNotifierProvider(
        create: (_) => fakeTotemViewModel(api),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: locale,
          home: const Scaffold(body: SingleChildScrollView(child: Padding(padding: EdgeInsets.all(16), child: BedtimeStory()))),
        ),
      );

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  FakeTotemApi withBedtime({bool enabled = false, int hour = 20, int minute = 0}) =>
      FakeTotemApi()..current = pairedTotem().copyWith(bedtime: TotemBedtime(enabled: enabled, hour: hour, minute: minute));

  String text(WidgetTester tester, String key) => tester.widget<Text>(find.descendant(of: find.byKey(Key(key)), matching: find.byType(Text))).data!;

  group('TotemBedtime', () {
    test('reads the backend answer and tolerates a missing or odd one', () {
      final parsed = TotemBedtime.fromJson({'enabled': true, 'hour': 19, 'minute': 45});
      expect([parsed.enabled, parsed.hour, parsed.minute], [true, 19, 45]);

      final odd = TotemBedtime.fromJson({'enabled': 'yes', 'hour': 99, 'minute': -3});
      expect([odd.enabled, odd.hour, odd.minute], [false, 23, 0]);

      final none = TotemBedtime.fromJson(null);
      expect([none.enabled, none.hour, none.minute], [false, 20, 0], reason: 'an older backend has no schedule');
      expect(TotemInfo.fromJson({'paired': true}).bedtime.hour, 20);
    });
  });

  group('Auto Bedtime Story', () {
    testWidgets('without a totem everything is locked and says why', (tester) async {
      await tester.pumpWidget(app(FakeTotemApi()));
      await settle(tester);

      expect(tester.widget<Switch>(find.byKey(const Key('bedtime-switch'))).onChanged, isNull);
      expect(find.byKey(const Key('bedtime-hint')), findsOneWidget);

      await tester.tap(find.byKey(const Key('bedtime-hour')));
      await settle(tester);
      expect(find.byType(TimePickerDialog), findsNothing);
    });

    testWidgets('shows the saved time in 12-hour form', (tester) async {
      await tester.pumpWidget(app(withBedtime(hour: 20, minute: 5)));
      await settle(tester);

      expect(text(tester, 'bedtime-hour'), '08');
      expect(text(tester, 'bedtime-minute'), '05');
      expect(find.byKey(const Key('bedtime-hint')), findsNothing);
    });

    testWidgets('midnight reads as 12', (tester) async {
      await tester.pumpWidget(app(withBedtime(hour: 0, minute: 0)));
      await settle(tester);
      expect(text(tester, 'bedtime-hour'), '12');
      expect(tester.widget<Text>(find.text('AM')).data, 'AM');
    });

    testWidgets('noon reads as 12 as well', (tester) async {
      await tester.pumpWidget(app(withBedtime(hour: 12, minute: 30)));
      await settle(tester);
      expect(text(tester, 'bedtime-hour'), '12');
      expect(text(tester, 'bedtime-minute'), '30');
    });

    testWidgets('the switch saves on and off, keeping the chosen time', (tester) async {
      final api = withBedtime(hour: 19, minute: 45);
      await tester.pumpWidget(app(api));
      await settle(tester);

      await tester.tap(find.byKey(const Key('bedtime-switch')));
      await settle(tester);
      expect(api.calls.last, 'bedtime:true:19:45');
      expect(tester.widget<Switch>(find.byKey(const Key('bedtime-switch'))).value, isTrue);

      await tester.tap(find.byKey(const Key('bedtime-switch')));
      await settle(tester);
      expect(api.calls.last, 'bedtime:false:19:45');
    });

    testWidgets('AM/PM moves the time by twelve hours and does nothing when already selected', (tester) async {
      final api = withBedtime(hour: 20, minute: 15);
      await tester.pumpWidget(app(api));
      await settle(tester);

      await tester.tap(find.byKey(const Key('bedtime-pm')));
      await settle(tester);
      expect(api.calls, isEmpty, reason: 'already PM');

      await tester.tap(find.byKey(const Key('bedtime-am')));
      await settle(tester);
      expect(api.calls.single, 'bedtime:false:8:15');
      expect(text(tester, 'bedtime-hour'), '08');

      await tester.tap(find.byKey(const Key('bedtime-pm')));
      await settle(tester);
      expect(api.calls.last, 'bedtime:false:20:15');
    });

    testWidgets('tapping the time opens the picker; cancelling saves nothing', (tester) async {
      final api = withBedtime();
      await tester.pumpWidget(app(api));
      await settle(tester);

      await tester.tap(find.byKey(const Key('bedtime-minute')));
      await settle(tester);
      expect(find.byType(TimePickerDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await settle(tester);
      expect(api.calls, isEmpty);
    });

    testWidgets('confirming the picker without a change saves nothing', (tester) async {
      final api = withBedtime(hour: 20, minute: 0);
      await tester.pumpWidget(app(api));
      await settle(tester);

      await tester.tap(find.byKey(const Key('bedtime-hour')));
      await settle(tester);
      await tester.tap(find.text('OK'));
      await settle(tester);

      expect(api.calls, isEmpty);
    });

    testWidgets('a failed save is reported and the shown time stays the saved one', (tester) async {
      final api = withBedtime(hour: 20, minute: 0)..error = const TotemApiException('x', statusCode: 404, code: 'totem_not_paired');
      await tester.pumpWidget(app(api));
      await settle(tester);

      await tester.tap(find.byKey(const Key('bedtime-am')));
      await settle(tester);

      expect(find.text('Link a totem first in Settings.'), findsOneWidget);
      expect(text(tester, 'bedtime-hour'), '08', reason: 'still 20:00 = 08 PM');
      expect(tester.widget<Switch>(find.byKey(const Key('bedtime-switch'))).value, isFalse);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('speaks Indonesian', (tester) async {
      await tester.pumpWidget(app(FakeTotemApi(), locale: const Locale('id')));
      await settle(tester);

      expect(find.text('Cerita Pengantar Tidur Otomatis'), findsOneWidget);
      expect(find.text('Hubungkan totem untuk mengatur cerita pengantar tidur.'), findsOneWidget);
    });
  });
}
