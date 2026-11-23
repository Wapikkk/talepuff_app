import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../core/relative_time.dart';
import '../../../data/models/account_result.dart';
import '../../../data/repositories/story_repository.dart';
import '../../view_models/phone_player/phone_player_view_model.dart';
import '../../view_models/story/story_detail_view_model.dart';
import '../../widgets/story/phone_controls.dart';
import 'story_detail_args.dart';
import '../../totem_flow.dart';
import '../../widgets/story/totem_controls.dart';
import '../../widgets/shared/top_banner.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_message_text.dart';
import '../../../l10n/l10n_labels.dart';
import '../../widgets/story/story_theme.dart';

class StoryDetailView extends StatelessWidget {
  const StoryDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final int? storyId = switch (arguments) {
      int id => id,
      StoryDetailArgs args => args.id,
      _ => null,
    };
    final autoPlay = arguments is StoryDetailArgs && arguments.autoPlay;

    return ChangeNotifierProvider(
      create: (context) {
        final viewModel = StoryDetailViewModel(repository: context.read<StoryRepository>());
        final phone = context.read<PhonePlayerViewModel>();
        if (storyId != null) {
          viewModel.load(storyId).then((_) {
            final story = viewModel.story;
            if (autoPlay && story != null) phone.play(story);
          });
        }
        return viewModel;
      },
      child: const _StopPhoneOnExit(child: _StoryDetailBody()),
    );
  }
}

class _StoryDetailBody extends StatelessWidget {
  const _StoryDetailBody();

  Future<void> _toggleFavorite(BuildContext context) async {
    final viewModel = context.read<StoryDetailViewModel>();
    final overlay = TopBanner.overlayOf(context);
    final l10n = AppLocalizations.of(context);
    final result = await viewModel.toggleFavorite();
    if (result is AccountFailure) TopBanner.show(overlay, l10n.appMessage(result.message), type: TopBannerType.error);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StoryDetailViewModel>();
    final story = viewModel.story;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.pop(context, viewModel.favoriteChanged);
      },
      child: Scaffold(
        backgroundColor: AppColors.darkPurple,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context, viewModel.favoriteChanged),
                    ),
                    const Spacer(),
                    if (story != null)
                      IconButton(
                        key: const Key('detail-favorite'),
                        icon: Icon(
                          story.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: story.isFavorite ? AppColors.dailyBox : Colors.white,
                        ),
                        onPressed: () => _toggleFavorite(context),
                      ),
                  ],
                ),
              ),
              Expanded(child: _content(context, viewModel)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context, StoryDetailViewModel viewModel) {
    final l10n = AppLocalizations.of(context);
    final story = viewModel.story;
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    if (story == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            viewModel.error == null ? l10n.storyLoadFailed : l10n.appMessage(viewModel.error!),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.redAccent, fontSize: 15, fontFamily: AppAssets.fontFamily),
          ),
        ),
      );
    }

    final style = StoryThemeStyle.of(story.theme);
    final paragraphs = story.content.split(RegExp(r'\n\s*\n')).map((p) => p.trim()).where((p) => p.isNotEmpty);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      children: [
        Text(
          story.title.isEmpty ? l10n.untitledStory : story.title,
          style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, fontFamily: AppAssets.fontFamily),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (story.theme.isNotEmpty) _chip(l10n.themeLabel(story.theme), style.color, style.iconColor),
            for (final mood in story.moods) _chip(l10n.moodLabel(mood), Colors.white24, Colors.white),
            if (story.lengthMinutes > 0) _chip(l10n.minutesShort(story.lengthMinutes), Colors.white24, Colors.white),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.storyCreated(RelativeTime.format(l10n, story.createdAt).toLowerCase()),
          style: const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: AppAssets.fontFamily),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            key: const Key('play-on-phone'),
            onPressed: () => context.read<PhonePlayerViewModel>().play(story),
            icon: const Icon(Icons.play_circle_fill, color: Colors.white),
            label: Text(
              l10n.playOnPhone,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: AppAssets.fontFamily),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.btnSave,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
          ),
        ),
        PhoneControls(storyId: story.id, sentences: story.sentences),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            key: const Key('play-on-totem'),
            onPressed: () => TotemFlow.playStory(context, story.id),
            icon: const Icon(Icons.speaker, color: Colors.white),
            label: Text(
              l10n.playOnTotem,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: AppAssets.fontFamily),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white54, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
          ),
        ),
        TotemControls(storyId: story.id, sentences: story.sentences),
        const SizedBox(height: 24),
        for (final paragraph in paragraphs)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Text(
              paragraph,
              style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.55, fontFamily: AppAssets.fontFamily),
            ),
          ),
      ],
    );
  }

  Widget _chip(String label, Color background, Color foreground) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(14)),
      child: Text(
        label,
        style: TextStyle(color: foreground, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: AppAssets.fontFamily),
      ),
    );
  }
}

/// Menghentikan pemutaran di HP saat layar cerita ditutup, supaya suara tidak jalan terus di layar lain.
class _StopPhoneOnExit extends StatefulWidget {
  final Widget child;
  const _StopPhoneOnExit({required this.child});

  @override
  State<_StopPhoneOnExit> createState() => _StopPhoneOnExitState();
}

class _StopPhoneOnExitState extends State<_StopPhoneOnExit> {
  // Dibaca di initState: saat dispose(), context sudah nonaktif dan tidak aman dipakai mencari provider.
  late final PhonePlayerViewModel _phone;

  @override
  void initState() {
    super.initState();
    _phone = context.read<PhonePlayerViewModel>();
  }

  @override
  void dispose() {
    Future.microtask(_phone.stop);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
