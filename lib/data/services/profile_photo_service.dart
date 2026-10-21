import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../core/server_address.dart';
import 'package:http/http.dart' as http;

import 'api_errors.dart';

class PhotoApiException implements Exception {
  final String message;
  final int? statusCode;
  final bool endpointMissing;
  const PhotoApiException(this.message, {this.statusCode, this.endpointMissing = false});

  @override
  String toString() => 'PhotoApiException($message, status: $statusCode)';
}

abstract class ProfilePhotoApi {
  Future<String> upload({required int childId, required String filePath});

  Future<void> remove({required int childId});
}

class ProfilePhotoService implements ProfilePhotoApi {
  ProfilePhotoService({required http.Client client, String? baseUrl, Duration timeout = const Duration(seconds: 30)})
      : _client = client,
        _baseUrlOverride = baseUrl,
        _timeout = timeout;

  final http.Client _client;
  final String? _baseUrlOverride;
  final Duration _timeout;

  String get _baseUrl => _baseUrlOverride ?? "${ServerAddress.baseUrl}/api";

  @override
  Future<String> upload({required int childId, required String filePath}) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$_baseUrl/child/upload-photo/$childId'))
        ..files.add(await http.MultipartFile.fromPath('photo', filePath));
      final streamed = await _client.send(request).timeout(_timeout);
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode != 200) {
        throw PhotoApiException('Server responded ${response.statusCode}', statusCode: response.statusCode, endpointMissing: isMissingEndpoint(response));
      }
      final url = (jsonDecode(response.body) as Map<String, dynamic>)['url'];
      if (url is! String || !url.startsWith('/')) {
        throw const PhotoApiException('Unexpected response from the server');
      }
      return url;
    } on TimeoutException {
      throw const PhotoApiException('Server did not respond in time');
    } on SocketException catch (e) {
      throw PhotoApiException('Cannot reach the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw PhotoApiException('Cannot reach the server: ${e.message}');
    } on FileSystemException catch (e) {
      throw PhotoApiException('Cannot read the photo: ${e.message}');
    } on FormatException {
      throw const PhotoApiException('Unexpected response from the server');
    } on TypeError {
      throw const PhotoApiException('Unexpected response from the server');
    }
  }

  @override
  Future<void> remove({required int childId}) async {
    try {
      final response = await _client.delete(Uri.parse('$_baseUrl/child/$childId/photo')).timeout(_timeout);
      if (response.statusCode != 200) {
        throw PhotoApiException('Server responded ${response.statusCode}', statusCode: response.statusCode, endpointMissing: isMissingEndpoint(response));
      }
    } on TimeoutException {
      throw const PhotoApiException('Server did not respond in time');
    } on SocketException catch (e) {
      throw PhotoApiException('Cannot reach the server: ${e.message}');
    } on http.ClientException catch (e) {
      throw PhotoApiException('Cannot reach the server: ${e.message}');
    }
  }
}
