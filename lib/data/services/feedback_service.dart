import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'api_errors.dart';

class FeedbackApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool endpointMissing;
  const FeedbackApiException(this.message, {this.statusCode, this.endpointMissing = false});

  @override
  String toString() => 'FeedbackApiException($message, status: $statusCode)';
}

abstract class FeedbackApi {
  Future<void> send({required String category, required String message, required String appVersion});
}

class FeedbackService implements FeedbackApi {
  FeedbackService({required http.Client client, String? baseUrl, Duration timeout = const Duration(seconds: 10)})
      : _client = client,
        _baseUrlOverride = baseUrl,
        _timeout = timeout;

  final http.Client _client;
  final String? _baseUrlOverride;
  final Duration _timeout;

  String get _baseUrl => _baseUrlOverride ?? "${dotenv.env['API_BASE_URL'] ?? ''}/api";

  @override
  Future<void> send({required String category, required String message, required String appVersion}) async {
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/feedback'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'category': category, 'message': message, 'app_version': appVersion}),
          )
          .timeout(_timeout);
      if (response.statusCode != 201 && response.statusCode != 200) {
        throw FeedbackApiException('Server responded ${response.statusCode}', statusCode: response.statusCode, endpointMissing: isMissingEndpoint(response));
      }
    } on TimeoutException {
      throw const FeedbackApiException('Server did not respond in time');
    } on SocketException catch (e) {
      throw FeedbackApiException('Cannot reach the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw FeedbackApiException('Cannot reach the server: ${e.message}');
    }
  }
}
