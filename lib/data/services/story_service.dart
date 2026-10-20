import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/story.dart';
import 'api_errors.dart';

class StoryApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool endpointMissing;
  const StoryApiException(
    this.message, {
    this.statusCode,
    this.endpointMissing = false,
  });

  @override
  String toString() => 'StoryApiException($message, status: $statusCode)';
}

abstract class StoryApi {
  Future<StoryPage> list({
    required int childId,
    required StoryTab tab,
    String query = '',
    int offset = 0,
    int limit = StoryService.pageSize,
  });

  Future<StoryDetail> get(int id);

  Future<void> setFavorite(int id, bool favorite);
  Future<void> delete(int id);
}

class StoryService implements StoryApi {
  StoryService({
    required http.Client client,
    String? baseUrl,
    Duration timeout = const Duration(seconds: 15),
  }) : _client = client,
       _baseUrlOverride = baseUrl,
       _timeout = timeout;

  static const int pageSize = 30;

  final http.Client _client;
  final String? _baseUrlOverride;
  final Duration _timeout;

  String get _baseUrl =>
      _baseUrlOverride ?? "${dotenv.env['API_BASE_URL'] ?? ''}/api";

  @override
  Future<StoryPage> list({
    required int childId,
    required StoryTab tab,
    String query = '',
    int offset = 0,
    int limit = pageSize,
  }) async {
    final uri = Uri.parse('$_baseUrl/stories').replace(
      queryParameters: {
        'child_id': '$childId',
        'tab': tab.apiValue,
        if (query.isNotEmpty) 'q': query,
        'limit': '$limit',
        'offset': '$offset',
      },
    );
    final body = await _send(() => _client.get(uri), expectedStatus: 200);
    try {
      final data = jsonDecode(body) as Map<String, dynamic>;
      final stories = (data['stories'] as List)
          .map((item) => StorySummary.fromJson(item as Map<String, dynamic>))
          .toList();
      return StoryPage(stories, hasMore: data['has_more'] == true);
    } on FormatException {
      throw const StoryApiException('Unexpected response from the server');
    } on TypeError {
      throw const StoryApiException('Unexpected response from the server');
    }
  }

  @override
  Future<StoryDetail> get(int id) async {
    final body = await _send(
      () => _client.get(Uri.parse('$_baseUrl/stories/$id')),
      expectedStatus: 200,
    );
    try {
      final data =
          (jsonDecode(body) as Map<String, dynamic>)['data']
              as Map<String, dynamic>;
      return StoryDetail.fromJson(data);
    } on FormatException {
      throw const StoryApiException('Unexpected response from the server');
    } on TypeError {
      throw const StoryApiException('Unexpected response from the server');
    }
  }

  @override
  Future<void> setFavorite(int id, bool favorite) async {
    await _send(
      () => _client.put(
        Uri.parse('$_baseUrl/stories/$id/favorite'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'favorite': favorite}),
      ),
      expectedStatus: 200,
    );
  }

  @override
  Future<void> delete(int id) async {
    await _send(
      () => _client.delete(Uri.parse('$_baseUrl/stories/$id')),
      expectedStatus: 200,
    );
  }

  Future<String> _send(
    Future<http.Response> Function() request, {
    required int expectedStatus,
  }) async {
    try {
      final response = await request().timeout(_timeout);
      if (response.statusCode != expectedStatus) {
        throw StoryApiException(
          'Server responded ${response.statusCode}',
          statusCode: response.statusCode,
          endpointMissing: isMissingEndpoint(response),
        );
      }
      return response.body;
    } on TimeoutException {
      throw const StoryApiException('Server did not respond in time');
    } on SocketException catch (e) {
      throw StoryApiException('Cannot reach the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw StoryApiException('Cannot reach the server: ${e.message}');
    }
  }
}
