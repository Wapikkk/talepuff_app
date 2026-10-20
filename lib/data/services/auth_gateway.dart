import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthUser {
  final String uid;
  final String? email;
  const AuthUser(this.uid, this.email);
}

enum AuthGatewayError {
  emailInUse,
  invalidCredentials,
  userNotFound,
  weakPassword,
  tooManyRequests,
  network,
  cancelled,
  unknown,
}

class AuthFailure implements Exception {
  final AuthGatewayError error;
  final String? detail;
  const AuthFailure(this.error, [this.detail]);

  @override
  String toString() => 'AuthFailure($error${detail == null ? '' : ', $detail'})';
}

/// Satu-satunya pintu ke Firebase Auth dan Google Sign-In. Dipisah dari AuthRepository agar
/// logika autentikasi bisa diuji tanpa plugin.
abstract class AuthGateway {
  AuthUser? get currentUser;

  /// Menunggu Firebase selesai memulihkan sesi tersimpan, lalu mengembalikan penggunanya.
  Future<AuthUser?> restoreUser();

  Future<AuthUser> signUpWithEmail(String email, String password);
  Future<AuthUser> signInWithEmail(String email, String password);

  /// Melempar [AuthFailure] dengan `cancelled` bila pengguna menutup pemilih akun.
  Future<AuthUser> signInWithGoogle();

  Future<void> signOut();
}

class FirebaseAuthGateway implements AuthGateway {
  FirebaseAuthGateway({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _google = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final GoogleSignIn _google;

  @override
  AuthUser? get currentUser => _toUser(_auth.currentUser);

  @override
  Future<AuthUser?> restoreUser() async {
    try {
      final user = await _auth.authStateChanges().first.timeout(const Duration(seconds: 5));
      return _toUser(user);
    } catch (_) {
      return currentUser;
    }
  }

  @override
  Future<AuthUser> signUpWithEmail(String email, String password) => _perform(
        () => _auth.createUserWithEmailAndPassword(email: email, password: password),
        expectedEmail: email,
      );

  @override
  Future<AuthUser> signInWithEmail(String email, String password) => _perform(
        () => _auth.signInWithEmailAndPassword(email: email, password: password),
        expectedEmail: email,
      );

  @override
  Future<AuthUser> signInWithGoogle() async {
    final GoogleSignInAccount? account;
    try {
      account = await _google.signIn();
    } on PlatformException catch (e) {
      debugPrint('[auth] google: chooser PlatformException ${e.code}: ${e.message}');
      throw _mapPlatform(e);
    }
    debugPrint('[auth] google: account chooser returned ${account == null ? 'null (cancelled)' : account.email}');
    if (account == null) throw const AuthFailure(AuthGatewayError.cancelled);

    final googleAuth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _perform(() => _auth.signInWithCredential(credential), expectedEmail: account.email);
  }

  @override
  Future<void> signOut() async {
    // Keluar dari Google juga, agar masuk berikutnya menampilkan pemilih akun
    // (bukan otomatis memakai akun sebelumnya).
    try {
      await _google.signOut();
    } catch (e) {
      debugPrint('Google sign-out failed: $e');
    }
    await _auth.signOut();
  }

  /// Menjalankan [action] lalu memastikan sesi Firebase benar-benar milik pengguna yang diharapkan.
  ///
  /// Plugin firebase_auth versi ini kadang melempar error cast (Pigeon) SETELAH operasi berhasil.
  /// Untuk kasus itu kita memeriksa `currentUser`; email yang diharapkan dicocokkan agar sesi lama
  /// milik orang lain tidak keliru dianggap hasil operasi ini.
  Future<AuthUser> _perform(Future<void> Function() action, {required String expectedEmail}) async {
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebase(e);
    } on PlatformException catch (e) {
      throw _mapPlatform(e);
    } catch (e) {
      debugPrint('Auth plugin threw after the call ($e); verifying the session instead.');
    }

    final user = _auth.currentUser;
    if (user == null || user.email?.toLowerCase() != expectedEmail.toLowerCase()) {
      throw const AuthFailure(AuthGatewayError.unknown);
    }
    return AuthUser(user.uid, user.email);
  }

  AuthUser? _toUser(User? user) => user == null ? null : AuthUser(user.uid, user.email);

  AuthFailure _mapFirebase(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return const AuthFailure(AuthGatewayError.emailInUse);
      case 'invalid-credential':
      case 'wrong-password':
      case 'invalid-email':
        return const AuthFailure(AuthGatewayError.invalidCredentials);
      case 'user-not-found':
        return const AuthFailure(AuthGatewayError.userNotFound);
      case 'weak-password':
        return const AuthFailure(AuthGatewayError.weakPassword);
      case 'too-many-requests':
        return const AuthFailure(AuthGatewayError.tooManyRequests);
      case 'network-request-failed':
        return const AuthFailure(AuthGatewayError.network);
      default:
        return AuthFailure(AuthGatewayError.unknown, e.message ?? e.code);
    }
  }

  AuthFailure _mapPlatform(PlatformException e) {
    switch (e.code) {
      case 'network_error':
        return const AuthFailure(AuthGatewayError.network);
      case 'sign_in_canceled':
        return const AuthFailure(AuthGatewayError.cancelled);
      case 'sign_in_failed':
        return const AuthFailure(
          AuthGatewayError.unknown,
          'Google sign-in failed. If this is a new build, make sure its SHA-1 is registered in Firebase.',
        );
      default:
        return AuthFailure(AuthGatewayError.unknown, e.message ?? e.code);
    }
  }
}
