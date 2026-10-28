import '../models/account_result.dart';
import '../models/app_message.dart';
import '../models/story.dart';
import '../models/story_job.dart';
import '../services/story_service.dart';

sealed class StoryListResult {
  const StoryListResult();
}

class StoryListLoaded extends StoryListResult {
  final List<StorySummary> stories;
  final bool hasMore;
  const StoryListLoaded(this.stories, {required this.hasMore});
}

class StoryListFailed extends StoryListResult {
  final AppMessage message;
  const StoryListFailed(this.message);
}

sealed class StoryDetailResult {
  const StoryDetailResult();
}

class StoryDetailLoaded extends StoryDetailResult {
  final StoryDetail story;
  const StoryDetailLoaded(this.story);
}

class StoryDetailFailed extends StoryDetailResult {
  final AppMessage message;
  const StoryDetailFailed(this.message);
}

sealed class StartJobResult {
  const StartJobResult();
}

class JobStarted extends StartJobResult {
  final int jobId;
  const JobStarted(this.jobId);
}

class JobStartFailed extends StartJobResult {
  final AppMessage message;
  const JobStartFailed(this.message);
}

sealed class JobCheckResult {
  const JobCheckResult();
}

class JobChecked extends JobCheckResult {
  final StoryJob job;
  const JobChecked(this.job);
}

class JobCheckFailed extends JobCheckResult {
  final AppMessage message;
  const JobCheckFailed(this.message);
}

sealed class LatestStoryResult {
  const LatestStoryResult();
}

class LatestStoryFound extends LatestStoryResult {
  final StorySummary story;
  const LatestStoryFound(this.story);
}

class LatestStoryNone extends LatestStoryResult {
  const LatestStoryNone();
}

class LatestStoryFailed extends LatestStoryResult {
  final AppMessage message;
  const LatestStoryFailed(this.message);
}

class StoryRepository {
  StoryRepository({required StoryApi api}) : _api = api;

  final StoryApi _api;

  Future<StoryListResult> list({
    required int childId,
    required StoryTab tab,
    String query = '',
    int offset = 0,
  }) async {
    try {
      final page = await _api.list(
        childId: childId,
        tab: tab,
        query: query,
        offset: offset,
      );
      return StoryListLoaded(page.stories, hasMore: page.hasMore);
    } on StoryApiException catch (e) {
      return StoryListFailed(_code(e));
    }
  }

  /// Cerita terbaru yang punya suara; dipakai tombol "Putar cerita terakhir".
  Future<LatestStoryResult> latestPlayable(int childId) async {
    final result = await list(childId: childId, tab: StoryTab.recent);
    switch (result) {
      case StoryListLoaded(:final stories):
        for (final story in stories) {
          if (story.hasAudio) return LatestStoryFound(story);
        }
        return const LatestStoryNone();
      case StoryListFailed(:final message):
        return LatestStoryFailed(message);
    }
  }

  Future<StoryDetailResult> get(int id) async {
    try {
      return StoryDetailLoaded(await _api.get(id));
    } on StoryApiException catch (e) {
      return StoryDetailFailed(_code(e));
    }
  }

  Future<AccountResult> setFavorite(int id, bool favorite) async {
    try {
      await _api.setFavorite(id, favorite);
      return AccountSuccess(
        favorite ? AppMessage.favoriteAdded : AppMessage.favoriteRemoved,
        value: '$favorite',
      );
    } on StoryApiException catch (e) {
      return AccountFailure(_code(e));
    }
  }

  Future<AccountResult> delete(int id) async {
    try {
      await _api.delete(id);
      return const AccountSuccess(AppMessage.storyDeleted);
    } on StoryApiException catch (e) {
      if (e.statusCode == 404 && !e.endpointMissing) {
        return const AccountSuccess(AppMessage.storyDeleted);
      }
      return AccountFailure(_code(e));
    }
  }

  Future<StartJobResult> startJob(Map<String, dynamic> payload) async {
    try {
      return JobStarted(await _api.startJob(payload));
    } on StoryApiException catch (e) {
      return JobStartFailed(_code(e));
    }
  }

  Future<JobCheckResult> checkJob(int id) async {
    try {
      return JobChecked(await _api.getJob(id));
    } on StoryApiException catch (e) {
      return JobCheckFailed(_code(e));
    }
  }

  static AppMessage jobFailure(StoryJob job) => switch (job.errorCode) {
        'ai_unavailable' => AppMessage.jobAiUnavailable,
        'ai_failed' => AppMessage.jobAiFailed,
        'voice_failed' => AppMessage.jobVoiceFailed,
        'save_failed' => AppMessage.jobSaveFailed,
        'interrupted' => AppMessage.jobInterrupted,
        _ => AppMessage.jobFailed,
      };

  AppMessage _code(StoryApiException error) {
    if (error.endpointMissing) return AppMessage.backendOutdated;
    return switch (error.statusCode) {
      400 => AppMessage.requestNotUnderstood,
      401 || 403 => AppMessage.reloginRequired,
      404 => AppMessage.storyNotFound,
      _ => error.message == 'Unexpected response from the server'
          ? AppMessage.unreadableResponse
          : AppMessage.serverUnreachable,
    };
  }
}
