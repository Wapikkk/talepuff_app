import '../../core/validators.dart';
import '../models/account_result.dart';
import '../services/auth_gateway.dart';
import '../services/auth_service.dart';

class AccountRepository {
  AccountRepository({required AuthGateway gateway, required ProfileApi api})
      : _gateway = gateway,
        _api = api;

  final AuthGateway _gateway;
  final ProfileApi _api;

  static const _managedByGoogle =
      'This account signs in with Google, so its email and password are managed by Google.';
  static const _serverUnreachable =
      "Can't reach the server. Make sure the backend is running and you're on the same network.";

  bool get canManageCredentials => _gateway.usesPassword;

  Future<AccountResult> updateChildName({required int childId, required String name}) async {
    final error = AuthValidators.childName(name);
    if (error != null) return AccountFailure(error);

    final trimmed = name.trim();
    try {
      await _api.updateChildName(childId: childId, name: trimmed);
    } on ProfileApiException catch (e) {
      switch (e.statusCode) {
        case 400:
          return const AccountFailure("The server didn't accept this name. Use letters only, up to 30 characters.");
        case 401:
        case 403:
          return const AccountFailure('For security, please log out and login again, then try once more.');
        case 404:
          return const AccountFailure("We couldn't find this child's profile. Please log out and login again.");
        default:
          return const AccountFailure(_serverUnreachable);
      }
    }
    return AccountSuccess('Name updated successfully!', value: trimmed);
  }

  Future<AccountResult> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (!canManageCredentials) return const AccountFailure(_managedByGoogle);

    final current = currentPassword.trim();
    final next = newPassword.trim();
    if (current.isEmpty) return const AccountFailure('Current password is required!');
    final passwordError = AuthValidators.newPassword(next);
    if (passwordError != null) return AccountFailure(passwordError);
    if (next != confirmPassword.trim()) return const AccountFailure('Passwords do not match!');
    if (next == current) return const AccountFailure('New password must be different from the current one.');

    try {
      await _gateway.changePassword(currentPassword: current, newPassword: next);
    } on AuthFailure catch (e) {
      return AccountFailure(_message(e));
    }
    return const AccountSuccess('Password updated successfully!');
  }

  Future<AccountResult> requestEmailChange({required String newEmail, required String currentPassword}) async {
    if (!canManageCredentials) return const AccountFailure(_managedByGoogle);

    final emailError = AuthValidators.email(newEmail);
    if (emailError != null) return AccountFailure(emailError);
    final email = newEmail.trim();
    if (email.toLowerCase() == _gateway.currentUser?.email?.toLowerCase()) {
      return const AccountFailure('This is already your email address.');
    }
    final current = currentPassword.trim();
    if (current.isEmpty) return const AccountFailure('Current password is required!');

    try {
      await _gateway.requestEmailChange(currentPassword: current, newEmail: email);
    } on AuthFailure catch (e) {
      return AccountFailure(_message(e));
    }
    return AccountSuccess(
      'We sent a verification link to $email. Your email changes after you open the link.',
      value: email,
    );
  }

  String _message(AuthFailure failure) {
    switch (failure.error) {
      case AuthGatewayError.invalidCredentials:
        return 'Current password is incorrect.';
      case AuthGatewayError.weakPassword:
        return 'This password is too weak. Please choose a stronger one.';
      case AuthGatewayError.emailInUse:
        return 'This email is already used by another account.';
      case AuthGatewayError.invalidEmail:
        return 'Invalid email format, please check again!';
      case AuthGatewayError.requiresRecentLogin:
      case AuthGatewayError.sessionExpired:
        return 'For security, please log out and login again, then try once more.';
      case AuthGatewayError.tooManyRequests:
        return 'Too many attempts. Please try again later.';
      case AuthGatewayError.network:
        return 'No connection. Check your internet and try again.';
      case AuthGatewayError.userNotFound:
      case AuthGatewayError.cancelled:
      case AuthGatewayError.unknown:
        return failure.detail ?? 'Something went wrong. Please try again.';
    }
  }
}
