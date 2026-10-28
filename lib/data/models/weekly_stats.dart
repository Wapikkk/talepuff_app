class DayStats {
  final DateTime date;
  final int stories;
  final int plays;
  final int seconds;

  const DayStats({required this.date, this.stories = 0, this.plays = 0, this.seconds = 0});

  factory DayStats.fromJson(Map<String, dynamic> json) {
    int number(Object? value) => value is num ? value.toInt() : 0;
    return DayStats(
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0),
      stories: number(json['stories']),
      plays: number(json['plays']),
      seconds: number(json['seconds']),
    );
  }

  int get minutes => seconds <= 0 ? 0 : (seconds / 60).round().clamp(1, 1 << 30);
}

class WeeklyStats {
  final List<DayStats> days;

  const WeeklyStats(this.days);

  factory WeeklyStats.fromJson(Map<String, dynamic> json) {
    final raw = json['days'];
    if (raw is! List) throw const FormatException('days is missing');
    return WeeklyStats([for (final day in raw) DayStats.fromJson(day as Map<String, dynamic>)]);
  }

  int get stories => days.fold(0, (sum, day) => sum + day.stories);
  int get plays => days.fold(0, (sum, day) => sum + day.plays);
  int get seconds => days.fold(0, (sum, day) => sum + day.seconds);
  int get minutes => seconds <= 0 ? 0 : (seconds / 60).round().clamp(1, 1 << 30);
  int get maxSeconds => days.fold(0, (best, day) => day.seconds > best ? day.seconds : best);
  bool get isEmpty => stories == 0 && plays == 0;
}
