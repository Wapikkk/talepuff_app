import '../models/account_result.dart';
import '../services/api_errors.dart';
import '../services/profile_photo_service.dart';

class ProfilePhotoRepository {
  ProfilePhotoRepository({required ProfilePhotoApi api}) : _api = api;

  final ProfilePhotoApi _api;

  static const _unreachable =
      "Can't reach the server. Make sure the backend is running and you're on the same network.";
  Future<AccountResult> upload({required int childId, required String filePath}) async {
    try {
      final url = await _api.upload(childId: childId, filePath: filePath);
      return AccountSuccess('Profile photo updated!', value: url);
    } on PhotoApiException catch (e) {
      return AccountFailure(_message(e, uploading: true));
    }
  }

  Future<AccountResult> remove({required int childId}) async {
    try {
      await _api.remove(childId: childId);
      return const AccountSuccess('Profile photo removed.');
    } on PhotoApiException catch (e) {
      return AccountFailure(_message(e, uploading: false));
    }
  }

  String _message(PhotoApiException error, {required bool uploading}) {
    if (error.endpointMissing) return outdatedBackendMessage;
    switch (error.statusCode) {
      case 400:
      case 415:
        return uploading
            ? "That file isn't a supported photo. Please use a JPG, PNG or WebP image."
            : "The server didn't accept this request.";
      case 413:
        return 'That photo is too large. Please choose one under 5 MB.';
      case 401:
      case 403:
        return 'For security, please log out and login again, then try once more.';
      case 404:
        return "We couldn't find this child's profile. Please log out and login again.";
      default:
        return error.message.startsWith('Cannot read the photo')
            ? "We couldn't read that photo. Please choose another one."
            : _unreachable;
    }
  }
}
