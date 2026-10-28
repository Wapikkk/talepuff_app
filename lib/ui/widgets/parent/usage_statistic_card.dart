import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../data/models/weekly_stats.dart';
import '../../../l10n/app_localizations.dart';
import '../../../l10n/app_message_text.dart';
import '../../view_models/parents/parent_view_model.dart';
import '../../view_models/stats/stats_view_model.dart';

/// Ringkasan tujuh hari terakhir: cerita dibuat, berapa kali diputar di totem, dan lama didengar.
class UsageStatisticCard extends StatefulWidget {
  const UsageStatisticCard({super.key});

  @override
  State<UsageStatisticCard> createState() => _UsageStatisticCardState();
}

class _UsageStatisticCardState extends State<UsageStatisticCard> {
  static const double _barArea = 56;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    if (!mounted) return;
    context.read<StatsViewModel>().load(context.read<ParentViewModel>().currentChildId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final viewModel = context.watch<StatsViewModel>();
    final name = context.watch<ParentViewModel>().currentChildName ?? '';
    final stats = viewModel.stats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.statsTitle(name),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkPurple,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
        const SizedBox(height: 16),
        if (stats != null)
          _content(context, l10n, stats)
        else if (viewModel.isLoading)
          const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
        else if (viewModel.error != null)
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.appMessage(viewModel.error!),
                  key: const Key('stats-error'),
                  style: const TextStyle(color: Colors.redAccent, fontSize: 14, fontFamily: AppAssets.fontFamily),
                ),
              ),
              TextButton(key: const Key('stats-retry'), onPressed: _load, child: Text(l10n.tryAgain)),
            ],
          ),
      ],
    );
  }

  Widget _content(BuildContext context, AppLocalizations l10n, WeeklyStats stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _legend(AppColors.adventureBox, l10n.statsStories(stats.stories), const Key('stats-stories')),
            _legend(AppColors.storiesCount, l10n.statsPlays(stats.plays), const Key('stats-plays')),
            _legend(AppColors.underline, l10n.statsMinutes(stats.minutes), const Key('stats-minutes')),
          ],
        ),
        const SizedBox(height: 16),
        if (stats.isEmpty)
          Text(
            l10n.statsEmpty,
            key: const Key('stats-empty'),
            style: const TextStyle(color: AppColors.slideBubble, fontSize: 14, fontFamily: AppAssets.fontFamily),
          )
        else
          SizedBox(
            height: _barArea + 24,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (var i = 0; i < stats.days.length; i++)
                  Expanded(child: _bar(context, stats.days[i], stats.maxSeconds, today: i == stats.days.length - 1)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _bar(BuildContext context, DayStats day, int maxSeconds, {required bool today}) {
    final height = maxSeconds == 0 ? 4.0 : (_barArea * day.seconds / maxSeconds).clamp(4.0, _barArea);
    final weekday = MaterialLocalizations.of(context).narrowWeekdays[day.date.weekday % 7];
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          key: Key('stats-bar-${day.date.day}'),
          width: 18,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.underline.withValues(alpha: today ? 1 : 0.4),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          weekday,
          style: TextStyle(
            fontSize: 12,
            fontWeight: today ? FontWeight.bold : FontWeight.w500,
            color: AppColors.darkPurple,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
      ],
    );
  }

  Widget _legend(Color color, String text, Key key) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(
          text,
          key: key,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.darkPurple,
            fontFamily: AppAssets.fontFamily,
          ),
        ),
      ],
    );
  }
}
