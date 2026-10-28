import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../data/models/account_result.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_message_text.dart';
import '../../view_models/totem/totem_view_model.dart';
import '../shared/top_banner.dart';

/// Cerita pengantar tidur otomatis: totem memutar cerita terbaru pada jam yang dipilih.
/// Jadwal disimpan di backend dan dijalankan di sana, jadi jalan walau HP tertutup.
class BedtimeStory extends StatefulWidget {
  const BedtimeStory({super.key});

  @override
  State<BedtimeStory> createState() => _BedtimeStoryState();
}

class _BedtimeStoryState extends State<BedtimeStory> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TotemViewModel>().refresh();
    });
  }

  Future<void> _save(BuildContext context, {required bool enabled, required int hour, required int minute}) async {
    final totem = context.read<TotemViewModel>();
    final overlay = TopBanner.overlayOf(context);
    final l10n = AppLocalizations.of(context);
    final result = await totem.setBedtime(enabled: enabled, hour: hour, minute: minute);
    if (result is AccountFailure) {
      TopBanner.show(overlay, l10n.appMessage(result.message), type: TopBannerType.error);
    }
  }

  Future<void> _pickTime(BuildContext context) async {
    final totem = context.read<TotemViewModel>();
    final current = totem.bedtime;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (picked == null || !context.mounted) return;
    if (picked.hour == current.hour && picked.minute == current.minute) return;
    await _save(context, enabled: current.enabled, hour: picked.hour, minute: picked.minute);
  }

  Future<void> _setAm(BuildContext context, bool am) async {
    final current = context.read<TotemViewModel>().bedtime;
    if ((current.hour < 12) == am) return;
    await _save(context, enabled: current.enabled, hour: (current.hour % 12) + (am ? 0 : 12), minute: current.minute);
  }

  @override
  Widget build(BuildContext context) {
    final totem = context.watch<TotemViewModel>();
    final l10n = AppLocalizations.of(context);
    final paired = totem.isPaired;
    final bedtime = totem.bedtime;
    final hour12 = bedtime.hour % 12 == 0 ? 12 : bedtime.hour % 12;
    final isAm = bedtime.hour < 12;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.bedtimeTitle,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkPurple,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
        Text(
          l10n.bedtimeSubtitle,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.darkPurple,
            fontFamily: AppAssets.fontFamily,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Transform.scale(
          scale: 0.8,
          alignment: Alignment.centerLeft,
          child: Switch(
            key: const Key('bedtime-switch'),
            value: paired && bedtime.enabled,
            activeColor: AppColors.darkPurple,
            onChanged: paired
                ? (value) => _save(context, enabled: value, hour: bedtime.hour, minute: bedtime.minute)
                : null,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.enterTime,
          style: const TextStyle(
            color: AppColors.slideBubble,
            fontWeight: FontWeight.bold,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _timeBox(const Key('bedtime-hour'), hour12.toString().padLeft(2, '0'), paired ? () => _pickTime(context) : null),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                ':',
                style: TextStyle(
                  fontSize: 24,
                  color: AppColors.slideBubble,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppAssets.fontFamily,
                ),
              ),
            ),
            _timeBox(const Key('bedtime-minute'), bedtime.minute.toString().padLeft(2, '0'), paired ? () => _pickTime(context) : null),
            const SizedBox(width: 15),
            _amPmSelector(context, isAm, paired),
          ],
        ),
        if (!paired) ...[
          const SizedBox(height: 8),
          Text(
            l10n.bedtimeNeedsTotem,
            key: const Key('bedtime-hint'),
            style: const TextStyle(color: AppColors.slideBubble, fontSize: 13, fontFamily: AppAssets.fontFamily),
          ),
        ],
      ],
    );
  }

  Widget _timeBox(Key key, String text, VoidCallback? onTap) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        width: 70,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.dividerLine,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 22,
            color: onTap == null ? Colors.grey : AppColors.darkPurple,
            fontFamily: AppAssets.fontFamily,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _amPmSelector(BuildContext context, bool isAm, bool enabled) {
    return Transform.scale(
      scale: 0.8,
      alignment: Alignment.centerLeft,
      child: Container(
        width: 55,
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.dividerLine,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              top: isAm ? 4 : 35,
              left: 4,
              right: 4,
              child: Container(
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.timeSelection,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Column(
              children: [
                _amPmOption(const Key('bedtime-am'), 'AM', isAm, enabled ? () => _setAm(context, true) : null),
                _amPmOption(const Key('bedtime-pm'), 'PM', !isAm, enabled ? () => _setAm(context, false) : null),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _amPmOption(Key key, String label, bool isSelected, VoidCallback? onTap) {
    return Expanded(
      child: GestureDetector(
        key: key,
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.darkPurple : Colors.grey,
              fontWeight: FontWeight.bold,
              fontFamily: AppAssets.fontFamily,
            ),
          ),
        ),
      ),
    );
  }
}
