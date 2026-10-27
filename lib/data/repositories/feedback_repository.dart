import '../../core/validators.dart';
import '../models/account_result.dart';
import '../models/app_message.dart';
import '../services/app_info.dart';
import '../services/feedback_service.dart';

class FeedbackRepository {
  FeedbackRepository({required FeedbackApi api, required AppInfo appInfo})
      : _api = api,
        _appInfo = appInfo;

  final FeedbackApi _api;
  final AppInfo _appInfo;

  static const categories = ['bug', 'idea', 'other'];

  Future<AccountResult> send({required String category, required String message}) async {
    if (!categories.contains(category)) return const AccountFailure(AppMessage.feedbackCategoryRequired);
    final error = FeedbackValidators.issue(message);
    if (error != null) return AccountFailure(error);

    String version;
    try {
      version = await _appInfo.versionCode();
    } catch (_) {
      version = '';
    }

    try {
      await _api.send(category: category, message: message.trim(), appVersion: version);
    } on FeedbackApiException catch (e) {
      if (e.endpointMissing) return const AccountFailure(AppMessage.backendOutdated);
      return AccountFailure(switch (e.statusCode) {
        400 => AppMessage.feedbackRejected,
        401 || 403 => AppMessage.reloginRequired,
        404 => AppMessage.accountNotFound,
        429 => AppMessage.feedbackRateLimited,
        _ => AppMessage.serverUnreachable,
      });
    }
    return const AccountSuccess(AppMessage.feedbackSent);
  }
}
