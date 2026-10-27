import '../models/account_result.dart';
import '../models/app_message.dart';
import '../services/profile_photo_service.dart';

class ProfilePhotoRepository {
  ProfilePhotoRepository({required ProfilePhotoApi api}) : _api = api;

  final ProfilePhotoApi _api;

  Future<AccountResult> upload({required int childId, required String filePath}) async {
    try {
      final url = await _api.upload(childId: childId, filePath: filePath);
      return AccountSuccess(AppMessage.photoUpdated, value: url);
    } on PhotoApiException catch (e) {
      return AccountFailure(_message(e, uploading: true));
    }
  }

  Future<AccountResult> remove({required int childId}) async {
    try {
      await _api.remove(childId: childId);
      return const AccountSuccess(AppMessage.photoRemoved);
    } on PhotoApiException catch (e) {
      return AccountFailure(_message(e, uploading: false));
    }
  }

  AppMessage _message(PhotoApiException error, {required bool uploading}) {
    if (error.endpointMissing) return AppMessage.backendOutdated;
    return switch (error.statusCode) {
      400 || 415 => uploading ? AppMessage.photoUnsupported : AppMessage.requestRejected,
      413 => AppMessage.photoTooLarge,
      401 || 403 => AppMessage.reloginRequired,
      404 => AppMessage.childProfileNotFound,
      _ => error.unreadable ? AppMessage.photoUnreadable : AppMessage.serverUnreachable,
    };
  }
}
