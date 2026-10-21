import '../models/account_result.dart';
import '../models/story.dart';
import '../models/story_job.dart';
import '../services/api_errors.dart';
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
  final String message;
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
  final String message;
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
  final String message;
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
  final String message;
  const JobCheckFailed(this.message);
}

class StoryRepository {
  StoryRepository({required StoryApi api}) : _api = api;

  final StoryApi _api;

  static const _unreachable =
      "Can't reach the server. Make sure the backend is running and you're on the same network.";

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
      return StoryListFailed(_message(e));
    }
  }

  Future<StoryDetailResult> get(int id) async {
    try {
      return StoryDetailLoaded(await _api.get(id));
    } on StoryApiException catch (e) {
      return StoryDetailFailed(_message(e));
    }
  }

  Future<AccountResult> setFavorite(int id, bool favorite) async {
    try {
      await _api.setFavorite(id, favorite);
      return AccountSuccess(
        favorite ? 'Added to favorites.' : 'Removed from favorites.',
        value: '$favorite',
      );
    } on StoryApiException catch (e) {
      return AccountFailure(_message(e));
    }
  }

  Future<AccountResult> delete(int id) async {
    try {
      await _api.delete(id);
      return const AccountSuccess('Story deleted.');
    } on StoryApiException catch (e) {
      if (e.statusCode == 404 && !e.endpointMissing) {
        return const AccountSuccess('Story deleted.');
      }
      return AccountFailure(_message(e));
    }
  }

  Future<StartJobResult> startJob(Map<String, dynamic> payload) async {
    try {
      return JobStarted(await _api.startJob(payload));
    } on StoryApiException catch (e) {
      return JobStartFailed(_message(e));
    }
  }

  Future<JobCheckResult> checkJob(int id) async {
    try {
      return JobChecked(await _api.getJob(id));
    } on StoryApiException catch (e) {
      return JobCheckFailed(_message(e));
    }
  }

  static String jobFailureMessage(StoryJob job) {
    switch (job.errorCode) {
      case 'ai_unavailable':
        return "The story service isn't running right now. Please try again in a moment.";
      case 'ai_failed':
        return "We couldn't write the story this time. Please try again.";
      case 'voice_failed':
        return "Your story was saved, but we couldn't create its voice.";
      case 'save_failed':
        return "We couldn't save the story. Please try again.";
      case 'interrupted':
        return 'The story was interrupted. Please try again.';
      default:
        return 'Something went wrong while creating the story. Please try again.';
    }
  }

  String _message(StoryApiException error) {
    if (error.endpointMissing) return outdatedBackendMessage;
    switch (error.statusCode) {
      case 400:
        return "The server didn't understand this request. Please try again.";
      case 401:
      case 403:
        return 'For security, please log out and login again, then try once more.';
      case 404:
        return "We couldn't find that story. It may have been removed.";
      default:
        return error.message == 'Unexpected response from the server'
            ? 'The server sent something we could not read. Please try again.'
            : _unreachable;
    }
  }
}
