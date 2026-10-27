import 'package:flutter/foundation.dart';
import '../models/app_message.dart';
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

  static const _sessionRejected = AuthFailed(AppMessage.sessionRejected, AuthFailureReason.unknown);
  static const _unreachable = AuthFailed(AppMessage.serverUnreachable, AuthFailureReason.network);
  static const _profileSyncFailed =
      AuthFailed(AppMessage.profileSyncFailed, AuthFailureReason.profileSyncFailed);

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
        return _sessionRejected;
      case ProfileUnreachable():
        return _unreachable;
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
        return const AuthFailed(AppMessage.googleAlreadyRegistered, AuthFailureReason.alreadyRegistered);
      case ProfileNotFound():
        return _registerThenEnter(user, child);
      case ProfileRejected():
        return _sessionRejected;
      case ProfileUnreachable():
        return _unreachable;
    }
  }

  Future<AuthResult> completeProfile(ChildDraft child) async {
    final user = _gateway.currentUser;
    if (user == null) return const SignedOut();

    final lookup = await _api.fetchProfile(user.uid);
    if (lookup is ProfileFound) return _enter(lookup.profile, user);
    if (lookup is ProfileRejected) return _sessionRejected;
    if (lookup is ProfileUnreachable) return _unreachable;
    return _registerThenEnter(user, child);
  }

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
        return _sessionRejected;
      case ProfileUnreachable():
        return _unreachable;
    }
  }

  Future<AuthResult> _registerThenEnter(AuthUser user, ChildDraft child) async {
    try {
      await _api.register(firebaseUid: user.uid, child: child);
    } on ProfileApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) return _sessionRejected;
      if (e.statusCode != 409) return _profileSyncFailed;
    }

    final lookup = await _api.fetchProfile(user.uid);
    if (lookup is ProfileFound) return _enter(lookup.profile, user);
    return _profileSyncFailed;
  }

  Future<AuthResult> _enter(ChildProfile profile, AuthUser user) async {
    await _session.saveActiveChildId(profile.id);
    debugPrint('[auth] entering app as child ${profile.id}');
    return SignedIn(profile, email: user.email);
  }

  AuthFailed _failed(AuthFailure failure) {
    switch (failure.error) {
      case AuthGatewayError.emailInUse:
        return const AuthFailed(AppMessage.emailInUse, AuthFailureReason.emailInUse);
      case AuthGatewayError.invalidCredentials:
        return const AuthFailed(AppMessage.invalidCredentials, AuthFailureReason.invalidCredentials);
      case AuthGatewayError.userNotFound:
        return const AuthFailed(AppMessage.userNotFound, AuthFailureReason.userNotFound);
      case AuthGatewayError.weakPassword:
        return const AuthFailed(AppMessage.weakPassword, AuthFailureReason.weakPassword);
      case AuthGatewayError.tooManyRequests:
        return const AuthFailed(AppMessage.tooManyRequests, AuthFailureReason.tooManyRequests);
      case AuthGatewayError.network:
        return const AuthFailed(AppMessage.noConnection, AuthFailureReason.network);
      case AuthGatewayError.invalidEmail:
        return const AuthFailed(AppMessage.emailInvalid, AuthFailureReason.invalidInput);
      case AuthGatewayError.requiresRecentLogin:
      case AuthGatewayError.sessionExpired:
        return const AuthFailed(AppMessage.sessionExpired, AuthFailureReason.unknown);
      case AuthGatewayError.googleSignInFailed:
        debugPrint('[auth] ${failure.detail}');
        return const AuthFailed(AppMessage.googleSignInFailed, AuthFailureReason.unknown);
      case AuthGatewayError.cancelled:
      case AuthGatewayError.unknown:
        debugPrint('[auth] unexpected failure: ${failure.detail}');
        return const AuthFailed(AppMessage.genericError, AuthFailureReason.unknown);
    }
  }
}
