import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_assets.dart';
import '../../../data/models/account_result.dart';
import '../../../data/models/story.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_message_text.dart';
import '../../../l10n/l10n_labels.dart';
import '../../view_models/totem/totem_view_model.dart';
import '../shared/top_banner.dart';

/// Remote untuk cerita yang sedang diputar di totem. Tidak tampil bila totem tidak memutar cerita ini.
class TotemControls extends StatefulWidget {
  final int storyId;
  final List<StorySentence> sentences;
  const TotemControls({super.key, required this.storyId, this.sentences = const []});

  @override
  State<TotemControls> createState() => _TotemControlsState();
}

class _TotemControlsState extends State<TotemControls> {
  late final TotemViewModel _viewModel;
  double? _dragVolume;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _viewModel = context.read<TotemViewModel>()..watch();
    // Kalimat berganti lebih sering daripada status dari totem datang, jadi layar dihitung ulang berkala.
    _tick = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted && widget.sentences.isNotEmpty && _viewModel.status.state == 'playing') setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    _viewModel.unwatch();
    super.dispose();
  }

  Future<void> _run(Future<AccountResult?> Function() action) async {
    final overlay = TopBanner.overlayOf(context);
    final l10n = AppLocalizations.of(context);
    final result = await action();
    if (result is AccountFailure) {
      TopBanner.show(overlay, l10n.appMessage(result.message), type: TopBannerType.error);
    }
  }

  static String _time(int seconds) => '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TotemViewModel>();
    final status = viewModel.status;
    if (!status.isPlayingStory(widget.storyId)) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    final paused = status.state == 'paused';
    final limit = viewModel.volumeLimit;
    final sentence = StorySentence.at(widget.sentences, viewModel.audiblePositionMs);
    const light = TextStyle(color: Colors.white, fontFamily: AppAssets.fontFamily);

    return Container(
      key: const Key('totem-controls'),
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.totemNowPlaying, style: light.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(
            '${l10n.totemStateLabel(status)}  ${_time(status.position)} / ${_time(status.duration)}',
            key: const Key('totem-progress'),
            style: light.copyWith(fontSize: 12, color: Colors.white70),
          ),
          if (sentence != null) ...[
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                sentence.text,
                key: ValueKey(sentence.startMs),
                semanticsLabel: sentence.text,
                style: light.copyWith(fontSize: 18, fontWeight: FontWeight.w600, height: 1.35),
              ),
            ),
          ],
          Row(
            children: [
              IconButton(
                key: const Key('totem-toggle'),
                icon: Icon(paused ? Icons.play_arrow : Icons.pause, color: Colors.white),
                onPressed: viewModel.isBusy ? null : () => _run(paused ? viewModel.resume : viewModel.pause),
              ),
              IconButton(
                key: const Key('totem-stop'),
                icon: const Icon(Icons.stop, color: Colors.white),
                onPressed: viewModel.isBusy ? null : () => _run(viewModel.stop),
              ),
              const Icon(Icons.volume_up, color: Colors.white70, size: 20),
              Expanded(
                child: Slider(
                  key: const Key('totem-volume'),
                  value: (_dragVolume ?? status.volume.toDouble()).clamp(0, limit < 1 ? 1 : limit).toDouble(),
                  max: limit < 1 ? 1 : limit.toDouble(),
                  label: '${(_dragVolume ?? status.volume).round()}',
                  activeColor: Colors.white,
                  inactiveColor: Colors.white24,
                  onChanged: limit == 0 ? null : (value) => setState(() => _dragVolume = value),
                  onChangeEnd: (value) async {
                    await _run(() => viewModel.setVolume(value.round()));
                    if (mounted) setState(() => _dragVolume = null);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
