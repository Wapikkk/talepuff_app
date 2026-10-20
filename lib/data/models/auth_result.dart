import 'child_profile.dart';

enum AuthMethod { 
  email, 
  google
}

enum AuthFailureReason {
  invalidInput,
  emailInUse,
  alreadyRegistered,
  invalidCredentials,
  userNotFound,
  weakPassword,
  tooManyRequests,
  network,
  profileSyncFailed,
  unknown,
}

sealed class AuthResult {
  const AuthResult();
}

class SignedIn extends AuthResult {
  final ChildProfile profile;
  final String? email;
  const SignedIn(this.profile, {this.email});
}

class NeedsProfile extends AuthResult {
  const NeedsProfile();
}

class SignedOut extends AuthResult {
  const SignedOut();
}

class AuthCancelled extends AuthResult {
  const AuthCancelled();
}

class AuthFailed extends AuthResult {
  final String message;
  final AuthFailureReason reason;
  const AuthFailed(this.message, this.reason);
}
