import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_assets.dart';
import '../../../data/models/story.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_message_text.dart';
import '../../view_models/phone_player/phone_player_view_model.dart';

/// Pemutar untuk cerita yang sedang didengarkan di HP ini. Tidak tampil bila pemutar tidak memegang cerita ini.
class PhoneControls extends StatelessWidget {
  final int storyId;
  final List<StorySentence> sentences;
  const PhoneControls({super.key, required this.storyId, this.sentences = const []});

  static String _clock(Duration d) => '${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PhonePlayerViewModel>();
    if (!player.isActive(storyId)) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context);
    const light = TextStyle(color: Colors.white, fontFamily: AppAssets.fontFamily);
    final box = BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(18));

    if (player.state == PhonePlayback.error) {
      return Container(
        key: const Key('phone-controls'),
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(16),
        decoration: box,
        child: Text(
          l10n.appMessage(player.error!),
          key: const Key('phone-error'),
          style: light.copyWith(color: Colors.redAccent, fontSize: 14),
        ),
      );
    }

    if (player.state == PhonePlayback.loading) {
      return Container(
        key: const Key('phone-controls'),
        margin: const EdgeInsets.only(top: 16),
        padding: const EdgeInsets.all(16),
        decoration: box,
        child: Row(
          children: [
            const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
            const SizedBox(width: 14),
            Expanded(child: Text(l10n.phoneLoading, key: const Key('phone-loading'), style: light)),
          ],
        ),
      );
    }

    final paused = player.state == PhonePlayback.paused;
    final total = player.duration.inMilliseconds;
    final position = player.position.inMilliseconds.clamp(0, total > 0 ? total : 1 << 30);
    final sentence = StorySentence.at(sentences, position);

    return Container(
      key: const Key('phone-controls'),
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: box,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.phoneNowPlaying, style: light.copyWith(fontWeight: FontWeight.bold)),
          if (sentence != null) ...[
            const SizedBox(height: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                sentence.text,
                key: ValueKey(sentence.startMs),
                style: light.copyWith(fontSize: 18, fontWeight: FontWeight.w600, height: 1.35),
              ),
            ),
          ],
          Row(
            children: [
              IconButton(
                key: const Key('phone-toggle'),
                icon: Icon(paused ? Icons.play_arrow : Icons.pause, color: Colors.white),
                onPressed: player.toggle,
              ),
              Expanded(
                child: Slider(
                  key: const Key('phone-seek'),
                  // Durasi bisa belum diketahui saat posisi sudah berjalan; nilai tidak boleh melewati batas penggeser.
                  value: position.toDouble().clamp(0, total > 0 ? total.toDouble() : 1).toDouble(),
                  max: total > 0 ? total.toDouble() : 1,
                  activeColor: Colors.white,
                  inactiveColor: Colors.white24,
                  onChanged: total > 0 ? (value) => player.seek(Duration(milliseconds: value.round())) : null,
                ),
              ),
              IconButton(
                key: const Key('phone-stop'),
                icon: const Icon(Icons.stop, color: Colors.white),
                onPressed: player.stop,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, bottom: 4),
            child: Text(
              '${_clock(player.position)} / ${_clock(player.duration)}',
              key: const Key('phone-progress'),
              style: light.copyWith(fontSize: 12, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
