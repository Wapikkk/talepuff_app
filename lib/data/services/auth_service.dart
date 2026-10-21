import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../core/server_address.dart';
import 'package:http/http.dart' as http;
import '../models/child_profile.dart';
import 'api_errors.dart';

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

class ProfileRejected extends ProfileLookup {
  const ProfileRejected();
}

class ProfileUnreachable extends ProfileLookup {
  final String reason;
  const ProfileUnreachable(this.reason);
}

class ProfileApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool endpointMissing;
  const ProfileApiException(this.message, {this.statusCode, this.endpointMissing = false});

  @override
  String toString() => 'ProfileApiException($message, status: $statusCode)';
}

abstract class ProfileApi {
  Future<ProfileLookup> fetchProfile(String firebaseUid);

  Future<void> register({
    required String firebaseUid,
    required String email,
    required ChildDraft child,
  });

  Future<void> updateChildName({required int childId, required String name});

  Future<void> updateMascot({required int childId, required String mascotId});
}

class AuthService implements ProfileApi {
  AuthService({required http.Client client, String? baseUrl, Duration timeout = const Duration(seconds: 8)})
      : _client = client,
        _baseUrlOverride = baseUrl,
        _timeout = timeout;

  final http.Client _client;
  final String? _baseUrlOverride;
  final Duration _timeout;

  String get _baseUrl => _baseUrlOverride ?? "${ServerAddress.baseUrl}/api";

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
        throw ProfileApiException('Server responded ${response.statusCode}', statusCode: response.statusCode, endpointMissing: isMissingEndpoint(response));
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
  Future<void> updateChildName({required int childId, required String name}) async {
    try {
      final response = await _client
          .put(
            Uri.parse('$_baseUrl/child/update-name/$childId'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'name': name}),
          )
          .timeout(_timeout);
      if (response.statusCode != 200) {
        throw ProfileApiException('Server responded ${response.statusCode}', statusCode: response.statusCode, endpointMissing: isMissingEndpoint(response));
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
  Future<void> updateMascot({required int childId, required String mascotId}) async {
    try {
      final response = await _client
          .put(
            Uri.parse('$_baseUrl/child/$childId/mascot'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'mascot_id': mascotId}),
          )
          .timeout(_timeout);
      if (response.statusCode != 200) {
        throw ProfileApiException('Server responded ${response.statusCode}', statusCode: response.statusCode, endpointMissing: isMissingEndpoint(response));
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
      debugPrint('[auth] fetchProfile failed against $_baseUrl: ${lookup.reason}');
    }
    if (lookup is ProfileRejected) {
      debugPrint('[auth] fetchProfile was rejected (401/403) by $_baseUrl: the Firebase token is missing or invalid');
    }
    return lookup;
  }

  Future<ProfileLookup> _fetchProfile(String firebaseUid) async {
    try {
      final response = await _client
          .get(Uri.parse('$_baseUrl/child/${Uri.encodeComponent(firebaseUid)}'))
          .timeout(_timeout);

      if (response.statusCode == 404) return const ProfileNotFound();
      if (response.statusCode == 401 || response.statusCode == 403) return const ProfileRejected();
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

}
