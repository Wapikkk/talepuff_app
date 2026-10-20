import '../../core/validators.dart';
import '../models/account_result.dart';
import '../services/api_errors.dart';
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
    if (!categories.contains(category)) return const AccountFailure('Please choose a category.');
    final error = FeedbackValidators.message(message);
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
      if (e.endpointMissing) return const AccountFailure(outdatedBackendMessage);
      switch (e.statusCode) {
        case 400:
          return const AccountFailure("The server didn't accept this message. Please check it and try again.");
        case 401:
        case 403:
          return const AccountFailure('For security, please log out and login again, then try once more.');
        case 404:
          return const AccountFailure("We couldn't find your account. Please log out and login again.");
        case 429:
          return const AccountFailure('You have sent a lot of feedback recently. Please try again later.');
        default:
          return const AccountFailure(
            "Can't reach the server. Make sure the backend is running and you're on the same network.",
          );
      }
    }
    return const AccountSuccess('Thank you for your feedback!');
  }
}
