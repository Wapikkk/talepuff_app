import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/server_address.dart';
import '../models/weekly_stats.dart';
import 'api_errors.dart';

class StatsApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool endpointMissing;
  const StatsApiException(this.message, {this.statusCode, this.endpointMissing = false});

  @override
  String toString() => 'StatsApiException($message, status: $statusCode)';
}

abstract class StatsApi {
  Future<WeeklyStats> weekly(int childId);
}

class StatsService implements StatsApi {
  StatsService({required http.Client client, String? baseUrl, Duration timeout = const Duration(seconds: 10)})
      : _client = client,
        _baseUrlOverride = baseUrl,
        _timeout = timeout;

  final http.Client _client;
  final String? _baseUrlOverride;
  final Duration _timeout;

  String get _baseUrl => _baseUrlOverride ?? '${ServerAddress.baseUrl}/api';

  @override
  Future<WeeklyStats> weekly(int childId) async {
    try {
      final response = await _client.get(Uri.parse('$_baseUrl/stats/weekly?child_id=$childId')).timeout(_timeout);
      if (response.statusCode != 200) {
        throw StatsApiException(
          'Server responded ${response.statusCode}',
          statusCode: response.statusCode,
          endpointMissing: isMissingEndpoint(response),
        );
      }
      return WeeklyStats.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } on TimeoutException {
      throw const StatsApiException('Server did not respond in time');
    } on SocketException catch (e) {
      throw StatsApiException('Cannot reach the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw StatsApiException('Cannot reach the server: ${e.message}');
    } on FormatException {
      throw const StatsApiException('Unexpected response from the server');
    } on TypeError {
      throw const StatsApiException('Unexpected response from the server');
    }
  }
}
