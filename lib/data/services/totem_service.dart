import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/server_address.dart';
import '../models/totem.dart';
import 'api_errors.dart';

class TotemApiException implements Exception {
  final String message;
  final int? statusCode;
  final String code; // `code` dari backend, mis. totem_offline
  final bool endpointMissing;
  const TotemApiException(this.message, {this.statusCode, this.code = '', this.endpointMissing = false});

  @override
  String toString() => 'TotemApiException($message, status: $statusCode, code: $code)';
}

abstract class TotemApi {
  Future<TotemInfo> info();
  Future<void> pair(String deviceId);
  Future<void> unpair();
  Future<void> play(int storyId, {int? volume});
  Future<void> command(String action, {int? value});
  Future<void> setVolumeLimit(int limit);
  Future<void> setBedtime({required bool enabled, required int hour, required int minute});
}

class TotemService implements TotemApi {
  TotemService({required http.Client client, String? baseUrl, Duration timeout = const Duration(seconds: 10)})
      : _client = client,
        _baseUrlOverride = baseUrl,
        _timeout = timeout;

  final http.Client _client;
  final String? _baseUrlOverride;
  final Duration _timeout;

  String get _baseUrl => _baseUrlOverride ?? '${ServerAddress.baseUrl}/api';

  static const _json = {'Content-Type': 'application/json'};

  @override
  Future<TotemInfo> info() async {
    final body = await _send(() => _client.get(Uri.parse('$_baseUrl/totem')));
    try {
      return TotemInfo.fromJson(jsonDecode(body) as Map<String, dynamic>);
    } on FormatException {
      throw const TotemApiException('Unexpected response from the server');
    } on TypeError {
      throw const TotemApiException('Unexpected response from the server');
    }
  }

  @override
  Future<void> pair(String deviceId) async {
    await _send(() => _client.post(Uri.parse('$_baseUrl/totem/pair'), headers: _json, body: jsonEncode({'device_id': deviceId})));
  }

  @override
  Future<void> unpair() async {
    await _send(() => _client.delete(Uri.parse('$_baseUrl/totem')));
  }

  @override
  Future<void> play(int storyId, {int? volume}) async {
    await _send(() => _client.post(
          Uri.parse('$_baseUrl/totem/play'),
          headers: _json,
          body: jsonEncode({'story_id': storyId, if (volume != null) 'volume': volume}),
        ));
  }

  @override
  Future<void> command(String action, {int? value}) async {
    await _send(() => _client.post(
          Uri.parse('$_baseUrl/totem/command'),
          headers: _json,
          body: jsonEncode({'action': action, if (value != null) 'value': value}),
        ));
  }

  @override
  Future<void> setVolumeLimit(int limit) async {
    await _send(() => _client.put(Uri.parse('$_baseUrl/totem/volume-limit'), headers: _json, body: jsonEncode({'limit': limit})));
  }

  @override
  Future<void> setBedtime({required bool enabled, required int hour, required int minute}) async {
    await _send(() => _client.put(
          Uri.parse('$_baseUrl/totem/bedtime'),
          headers: _json,
          body: jsonEncode({'enabled': enabled, 'hour': hour, 'minute': minute}),
        ));
  }

  Future<String> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(_timeout);
      if (response.statusCode != 200) {
        throw TotemApiException(
          'Server responded ${response.statusCode}',
          statusCode: response.statusCode,
          code: _code(response.body),
          endpointMissing: isMissingEndpoint(response),
        );
      }
      return response.body;
    } on TimeoutException {
      throw const TotemApiException('Server did not respond in time');
    } on SocketException catch (e) {
      throw TotemApiException('Cannot reach the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw TotemApiException('Cannot reach the server: ${e.message}');
    }
  }

  String _code(String body) {
    try {
      final data = jsonDecode(body);
      return data is Map ? data['code']?.toString() ?? '' : '';
    } catch (_) {
      return '';
    }
  }
}
