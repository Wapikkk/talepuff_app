import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talepuff_app/data/services/story_service.dart';
import 'package:talepuff_app/ui/view_models/create_story/create_story_view_model.dart';
import 'package:talepuff_app/ui/view_models/navbar_view_model.dart';
import 'package:talepuff_app/ui/views/create_story/create_story_view.dart';
import 'package:talepuff_app/ui/views/loading_screen/loading_screen_view.dart';

import '../support/fakes.dart';
import '../support/l10n.dart';
import 'story_result_test.dart' show phoneTest;

MaterialApp inIndonesian(Widget home) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('id'),
      home: home,
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({'active_child_id': 7}));

  group('Create screen in Indonesian', () {
    phoneTest('shows Indonesian labels but sends the same English values to the server', (tester) async {
      final viewModel = CreateStoryViewModel();
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: viewModel),
          ChangeNotifierProvider(create: (_) => NavbarViewModel()),
        ],
        child: inIndonesian(const Scaffold(body: CreateStoryView())),
      ));

      expect(find.text('Aku ingin cerita tentang...'), findsOneWidget);
      expect(find.text('Petualangan'), findsOneWidget);
      expect(find.text('5 Menit'), findsOneWidget);
      expect(find.text('Ceria'), findsOneWidget);
      expect(find.text('Lembut'), findsOneWidget);
      expect(find.text('Buat Cerita'), findsOneWidget);

      await tester.tap(find.text('Petualangan'));
      await tester.tap(find.text('5 Menit'));
      await tester.tap(find.text('Ceria'));
      await tester.tap(find.text('Lembut'));
      await tester.pump();

      final payload = viewModel.buildPayload(childId: 7);
      expect(payload['theme'], 'Adventure');
      expect(payload['length_minutes'], 5);
      expect(payload['mood'], 'Joyful');
      expect(payload['voice_tone'], 'Gentle');
    });

    phoneTest('the "choose" message lists what is missing in Indonesian', (tester) async {
      final viewModel = CreateStoryViewModel()..setCharacterName('Aira');
      await tester.pumpWidget(MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: viewModel),
          ChangeNotifierProvider(create: (_) => NavbarViewModel()),
        ],
        child: inIndonesian(const Scaffold(body: CreateStoryView())),
      ));

      await viewModel.generateStory(tester.element(find.byType(CreateStoryView)));
      await tester.pump();

      expect(find.text('Silakan pilih kategori, panjang cerita, suara.'), findsOneWidget);
    });
  });

  group('Loading screen in Indonesian', () {
    testWidgets('a failure is shown in Indonesian', (tester) async {
      final api = FakeStoryApi()..startError = const StoryApiException('down', statusCode: 400);
      await tester.pumpWidget(Provider.value(
        value: fakeStories(api),
        child: inIndonesian(const LoadingScreenView(payload: {'child_id': 7})),
      ));
      await tester.pump();
      await tester.pump();

      expect(find.text('Terjadi kesalahan'), findsOneWidget);
      expect(find.textContaining('tidak memahami'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);
      expect(find.text('Kembali'), findsOneWidget);
    });
  });
}
