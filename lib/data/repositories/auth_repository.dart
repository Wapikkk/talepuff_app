import 'package:flutter/foundation.dart';
import '../models/auth_result.dart';
import '../models/child_profile.dart';
import '../services/auth_gateway.dart';
import '../services/auth_service.dart';
import '../services/session_store.dart';

class AuthRepository {
  AuthRepository({
    required AuthGateway gateway,
    required ProfileApi api,
    required SessionStore session,
  })  : _gateway = gateway,
        _api = api,
        _session = session;

  final AuthGateway _gateway;
  final ProfileApi _api;
  final SessionStore _session;

  static const _sessionRejectedMessage = 'The server rejected your session. Please login again.';
  static const _unreachableMessage =
      "Can't reach the server. Make sure the backend is running and you're on the same network.";
  static const _profileSyncMessage =
      'Your account was created, but we could not save the profile. Check your connection and try again.';

  String? get currentEmail => _gateway.currentUser?.email;

  Future<AuthResult> restoreSession() async {
    final user = await _gateway.restoreUser();
    if (user == null) return const SignedOut();
    return _resolveProfile(user);
  }

  Future<AuthResult> signInWithEmail(String email, String password) async {
    final AuthUser user;
    try {
      user = await _gateway.signInWithEmail(email, password);
    } on AuthFailure catch (e) {
      return _failed(e);
    }
    return _resolveProfile(user);
  }

  Future<AuthResult> signUpWithEmail(String email, String password, ChildDraft child) async {
    final AuthUser user;
    try {
      user = await _gateway.signUpWithEmail(email, password);
    } on AuthFailure catch (e) {
      return _failed(e);
    }
    return _registerThenEnter(user, child);
  }

  Future<AuthResult> continueWithGoogle({ChildDraft? child}) async {
    final AuthUser user;
    try {
      user = await _gateway.signInWithGoogle();
    } on AuthFailure catch (e) {
      if (e.error == AuthGatewayError.cancelled) return const AuthCancelled();
      return _failed(e);
    }

    debugPrint('[auth] google: signed in to Firebase as ${user.email} (uid ${user.uid}); looking up profile');
    final lookup = await _api.fetchProfile(user.uid);
    debugPrint('[auth] google: profile lookup -> ${lookup.runtimeType}');
    switch (lookup) {
      case ProfileFound(:final profile):
        return _enter(profile, user);
      case ProfileNotFound():
        if (child == null) return const NeedsProfile();
        return _registerThenEnter(user, child);
      case ProfileRejected():
        return const AuthFailed(_sessionRejectedMessage, AuthFailureReason.unknown);
      case ProfileUnreachable():
        return const AuthFailed(_unreachableMessage, AuthFailureReason.network);
    }
  }

  Future<AuthResult> signUpWithGoogle(ChildDraft child) async {
    final AuthUser user;
    try {
      user = await _gateway.signInWithGoogle();
    } on AuthFailure catch (e) {
      if (e.error == AuthGatewayError.cancelled) return const AuthCancelled();
      return _failed(e);
    }

    final lookup = await _api.fetchProfile(user.uid);
    debugPrint('[auth] google sign-up: profile lookup -> ${lookup.runtimeType}');
    switch (lookup) {
      case ProfileFound():
        await _gateway.signOut();
        await _session.clear();
        return const AuthFailed(
          'This Google account is already registered. Please login instead.',
          AuthFailureReason.alreadyRegistered,
        );
      case ProfileNotFound():
        return _registerThenEnter(user, child);
      case ProfileRejected():
        return const AuthFailed(_sessionRejectedMessage, AuthFailureReason.unknown);
      case ProfileUnreachable():
        return const AuthFailed(_unreachableMessage, AuthFailureReason.network);
    }
  }

  Future<AuthResult> completeProfile(ChildDraft child) async {
    final user = _gateway.currentUser;
    if (user == null) return const SignedOut();

    final lookup = await _api.fetchProfile(user.uid);
    if (lookup is ProfileFound) return _enter(lookup.profile, user);
    if (lookup is ProfileRejected) {
      return const AuthFailed(_sessionRejectedMessage, AuthFailureReason.unknown);
    }
    if (lookup is ProfileUnreachable) {
      return const AuthFailed(_unreachableMessage, AuthFailureReason.network);
    }
    return _registerThenEnter(user, child);
  }

  /// Profil anak untuk pengguna yang sedang masuk, lewat API bertoken. Tanpa pengguna -> ProfileNotFound.
  Future<ProfileLookup> currentProfile() async {
    final user = _gateway.currentUser;
    if (user == null) return const ProfileNotFound();
    return _api.fetchProfile(user.uid);
  }

  Future<void> signOut() async {
    await _gateway.signOut();
    await _session.clear();
  }

  Future<AuthResult> _resolveProfile(AuthUser user) async {
    final lookup = await _api.fetchProfile(user.uid);
    switch (lookup) {
      case ProfileFound(:final profile):
        return _enter(profile, user);
      case ProfileNotFound():
        return const NeedsProfile();
      case ProfileRejected():
        return const AuthFailed(_sessionRejectedMessage, AuthFailureReason.unknown);
      case ProfileUnreachable():
        return const AuthFailed(_unreachableMessage, AuthFailureReason.network);
    }
  }

  Future<AuthResult> _registerThenEnter(AuthUser user, ChildDraft child) async {
    try {
      await _api.register(firebaseUid: user.uid, email: user.email ?? '', child: child);
    } on ProfileApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        return const AuthFailed(_sessionRejectedMessage, AuthFailureReason.unknown);
      }
      if (e.statusCode != 409) {
        return const AuthFailed(_profileSyncMessage, AuthFailureReason.profileSyncFailed);
      }
    }

    final lookup = await _api.fetchProfile(user.uid);
    if (lookup is ProfileFound) return _enter(lookup.profile, user);
    return const AuthFailed(_profileSyncMessage, AuthFailureReason.profileSyncFailed);
  }

  Future<AuthResult> _enter(ChildProfile profile, AuthUser user) async {
    await _session.saveActiveChildId(profile.id);
    debugPrint('[auth] entering app as child ${profile.id}');
    return SignedIn(profile, email: user.email);
  }

  AuthFailed _failed(AuthFailure failure) {
    switch (failure.error) {
      case AuthGatewayError.emailInUse:
        return const AuthFailed('This email is already registered. Please login.', AuthFailureReason.emailInUse);
      case AuthGatewayError.invalidCredentials:
        return const AuthFailed('Incorrect email or password. Please try again.', AuthFailureReason.invalidCredentials);
      case AuthGatewayError.userNotFound:
        return const AuthFailed('No account found for this email. Please sign up first.', AuthFailureReason.userNotFound);
      case AuthGatewayError.weakPassword:
        return const AuthFailed('This password is too weak. Please choose a stronger one.', AuthFailureReason.weakPassword);
      case AuthGatewayError.tooManyRequests:
        return const AuthFailed('Too many attempts. Please try again later.', AuthFailureReason.tooManyRequests);
      case AuthGatewayError.network:
        return const AuthFailed('No connection. Check your internet and try again.', AuthFailureReason.network);
      case AuthGatewayError.invalidEmail:
        return const AuthFailed('Invalid email format, please check again!', AuthFailureReason.invalidInput);
      case AuthGatewayError.requiresRecentLogin:
      case AuthGatewayError.sessionExpired:
        return const AuthFailed('Your session has expired. Please login again.', AuthFailureReason.unknown);
      case AuthGatewayError.cancelled:
      case AuthGatewayError.unknown:
        return AuthFailed(failure.detail ?? 'Something went wrong. Please try again.', AuthFailureReason.unknown);
    }
  }
}
