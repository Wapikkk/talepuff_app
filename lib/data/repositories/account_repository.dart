import '../../core/mascots.dart';
import '../../core/validators.dart';
import '../models/account_result.dart';
import '../models/app_message.dart';
import '../services/auth_gateway.dart';
import '../services/auth_service.dart';

class AccountRepository {
  AccountRepository({required AuthGateway gateway, required ProfileApi api})
      : _gateway = gateway,
        _api = api;

  final AuthGateway _gateway;
  final ProfileApi _api;

  bool get canManageCredentials => _gateway.usesPassword;

  Future<AccountResult> updateChildName({required int childId, required String name}) async {
    final error = AuthValidators.childNameIssue(name);
    if (error != null) return AccountFailure(error);

    final trimmed = name.trim();
    try {
      await _api.updateChildName(childId: childId, name: trimmed);
    } on ProfileApiException catch (e) {
      return AccountFailure(_apiFailure(e, rejected: AppMessage.childNameRejected));
    }
    return AccountSuccess(AppMessage.nameUpdated, value: trimmed);
  }

  Future<AccountResult> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (!canManageCredentials) return const AccountFailure(AppMessage.managedByGoogle);

    final current = currentPassword.trim();
    final next = newPassword.trim();
    if (current.isEmpty) return const AccountFailure(AppMessage.currentPasswordRequired);
    final passwordError = AuthValidators.newPasswordIssue(next);
    if (passwordError != null) return AccountFailure(passwordError);
    if (next != confirmPassword.trim()) return const AccountFailure(AppMessage.passwordsMismatch);
    if (next == current) return const AccountFailure(AppMessage.passwordSameAsCurrent);

    try {
      await _gateway.changePassword(currentPassword: current, newPassword: next);
    } on AuthFailure catch (e) {
      return AccountFailure(_message(e));
    }
    return const AccountSuccess(AppMessage.passwordUpdated);
  }

  Future<AccountResult> requestEmailChange({required String newEmail, required String currentPassword}) async {
    if (!canManageCredentials) return const AccountFailure(AppMessage.managedByGoogle);

    final emailError = AuthValidators.emailIssue(newEmail);
    if (emailError != null) return AccountFailure(emailError);
    final email = newEmail.trim();
    if (email.toLowerCase() == _gateway.currentUser?.email?.toLowerCase()) {
      return const AccountFailure(AppMessage.sameEmail);
    }
    final current = currentPassword.trim();
    if (current.isEmpty) return const AccountFailure(AppMessage.currentPasswordRequired);

    try {
      await _gateway.requestEmailChange(currentPassword: current, newEmail: email);
    } on AuthFailure catch (e) {
      return AccountFailure(_message(e));
    }
    return AccountSuccess(AppMessage.verificationSent, value: email);
  }

  Future<AccountResult> updateMascot({required int childId, required String mascotId}) async {
    if (!Mascots.isValid(mascotId)) return const AccountFailure(AppMessage.mascotInvalid);

    try {
      await _api.updateMascot(childId: childId, mascotId: mascotId);
    } on ProfileApiException catch (e) {
      return AccountFailure(_apiFailure(e, rejected: AppMessage.mascotRejected));
    }
    return AccountSuccess(AppMessage.mascotUpdated, value: mascotId);
  }

  AppMessage _apiFailure(ProfileApiException e, {required AppMessage rejected}) {
    if (e.endpointMissing) return AppMessage.backendOutdated;
    return switch (e.statusCode) {
      400 => rejected,
      401 || 403 => AppMessage.reloginRequired,
      404 => AppMessage.childProfileNotFound,
      _ => AppMessage.serverUnreachable,
    };
  }

  AppMessage _message(AuthFailure failure) => switch (failure.error) {
        AuthGatewayError.invalidCredentials => AppMessage.currentPasswordIncorrect,
        AuthGatewayError.weakPassword => AppMessage.weakPassword,
        AuthGatewayError.emailInUse => AppMessage.emailInUse,
        AuthGatewayError.invalidEmail => AppMessage.emailInvalid,
        AuthGatewayError.requiresRecentLogin || AuthGatewayError.sessionExpired => AppMessage.reloginRequired,
        AuthGatewayError.tooManyRequests => AppMessage.tooManyRequests,
        AuthGatewayError.network => AppMessage.noConnection,
        AuthGatewayError.userNotFound ||
        AuthGatewayError.cancelled ||
        AuthGatewayError.googleSignInFailed ||
        AuthGatewayError.unknown =>
          AppMessage.genericError,
      };
}
