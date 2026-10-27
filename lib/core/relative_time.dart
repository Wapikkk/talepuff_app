import '../l10n/app_localizations.dart';

class RelativeTime {
  RelativeTime._();

  static String format(AppLocalizations l10n, DateTime then, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final difference = current.difference(then);

    if (difference.inMinutes < 1) return l10n.timeJustNow;
    if (difference.inMinutes < 60) return l10n.timeMinutesAgo(difference.inMinutes);
    if (difference.inHours < 24) return l10n.timeHoursAgo(difference.inHours);
    if (difference.inDays < 7) return l10n.timeDaysAgo(difference.inDays);

    return then.year == current.year ? l10n.timeDate(then) : l10n.timeDateYear(then);
  }
}
