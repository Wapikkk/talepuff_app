import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/child_profile.dart';

/// Hasil mencari profil anak di backend. Tiga keadaan dibedakan agar UI tidak salah memberi pesan:
/// "belum ada profil" sangat berbeda dari "server tidak terjangkau".
sealed class ProfileLookup {
  const ProfileLookup();
}

class ProfileFound extends ProfileLookup {
  final ChildProfile profile;
  final Map<String, dynamic> raw;
  const ProfileFound(this.profile, this.raw);
}

class ProfileNotFound extends ProfileLookup {
  const ProfileNotFound();
}

class ProfileUnreachable extends ProfileLookup {
  final String reason;
  const ProfileUnreachable(this.reason);
}

class ProfileApiException implements Exception {
  final String message;
  final int? statusCode;
  const ProfileApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ProfileApiException($message, status: $statusCode)';
}

/// Antarmuka ke backend untuk profil anak (dipisah agar mudah diganti objek palsu di tes).
abstract class ProfileApi {
  Future<ProfileLookup> fetchProfile(String firebaseUid);

  Future<void> register({
    required String firebaseUid,
    required String email,
    required ChildDraft child,
  });
}

class AuthService implements ProfileApi {
  AuthService({http.Client? client, String? baseUrl, Duration timeout = const Duration(seconds: 8)})
      : _client = client ?? http.Client(),
        _baseUrlOverride = baseUrl,
        _timeout = timeout;

  final http.Client _client;
  final String? _baseUrlOverride;
  final Duration _timeout;

  // Dibaca saat dipakai (bukan saat konstruksi) karena .env baru dimuat setelah objek dibuat.
  String get _baseUrl => _baseUrlOverride ?? "${dotenv.env['API_BASE_URL'] ?? ''}/api";

  @override
  Future<void> register({
    required String firebaseUid,
    required String email,
    required ChildDraft child,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'firebase_uid': firebaseUid,
              'email': email,
              'child_name': child.name,
              'age': child.age,
              'gender': child.gender,
              'interests': child.interests,
            }),
          )
          .timeout(_timeout * 2);

      if (response.statusCode != 200) {
        throw ProfileApiException('Server responded ${response.statusCode}', statusCode: response.statusCode);
      }
    } on TimeoutException {
      throw const ProfileApiException('Server did not respond in time');
    } on SocketException catch (e) {
      throw ProfileApiException('Cannot reach the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw ProfileApiException('Cannot reach the server: ${e.message}');
    }
  }

  @override
  Future<ProfileLookup> fetchProfile(String firebaseUid) async {
    final lookup = await _fetchProfile(firebaseUid);
    if (lookup is ProfileUnreachable) {
      // Alasan sebenarnya (timeout, status 500, isi balasan aneh, koneksi ditolak) hanya
      // tersedia di sini; pesan ke pengguna sengaja disederhanakan.
      debugPrint('[auth] fetchProfile failed against $_baseUrl: ${lookup.reason}');
    }
    return lookup;
  }

  Future<ProfileLookup> _fetchProfile(String firebaseUid) async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/child/${Uri.encodeComponent(firebaseUid)}'))
          .timeout(_timeout);

      if (response.statusCode == 404) return const ProfileNotFound();
      if (response.statusCode != 200) {
        return ProfileUnreachable('Server responded ${response.statusCode}');
      }
      final raw = jsonDecode(response.body) as Map<String, dynamic>;
      return ProfileFound(ChildProfile.fromJson(raw), raw);
    } on TimeoutException {
      return const ProfileUnreachable('Server did not respond in time');
    } on SocketException catch (e) {
      return ProfileUnreachable('Cannot reach the server: ${e.message}');
    } on http.ClientException catch (e) {
      return ProfileUnreachable('Cannot reach the server: ${e.message}');
    } on FormatException {
      return const ProfileUnreachable('Unexpected response from the server');
    } on TypeError {
      return const ProfileUnreachable('Unexpected response from the server');
    }
  }

  /// Kompatibilitas untuk pemanggil lama (HomeViewModel, ChildInfoViewModel.syncChildData):
  /// data mentah bila profil ada, selain itu null.
  Future<Map<String, dynamic>?> getChildInfo(String uid) async {
    final result = await fetchProfile(uid);
    if (result is ProfileFound) return result.raw;
    if (result is ProfileUnreachable) debugPrint('Failed to fetch child info: ${result.reason}');
    return null;
  }
}
