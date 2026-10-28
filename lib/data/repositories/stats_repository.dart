import '../models/app_message.dart';
import '../models/weekly_stats.dart';
import '../services/stats_service.dart';

sealed class StatsResult {
  const StatsResult();
}

class StatsLoaded extends StatsResult {
  final WeeklyStats stats;
  const StatsLoaded(this.stats);
}

class StatsFailed extends StatsResult {
  final AppMessage message;
  const StatsFailed(this.message);
}

class StatsRepository {
  StatsRepository({required StatsApi api}) : _api = api;

  final StatsApi _api;

  Future<StatsResult> weekly(int childId) async {
    try {
      return StatsLoaded(await _api.weekly(childId));
    } on StatsApiException catch (e) {
      return StatsFailed(_code(e));
    }
  }

  AppMessage _code(StatsApiException e) {
    if (e.endpointMissing) return AppMessage.backendOutdated;
    return switch (e.statusCode) {
      401 || 403 => AppMessage.reloginRequired,
      404 => AppMessage.childProfileNotFound,
      400 => AppMessage.requestNotUnderstood,
      _ => e.message == 'Unexpected response from the server' ? AppMessage.unreadableResponse : AppMessage.serverUnreachable,
    };
  }
}
