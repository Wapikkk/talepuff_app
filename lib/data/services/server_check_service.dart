import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

sealed class ServerCheckResult {
  const ServerCheckResult();
}

class ServerReachable extends ServerCheckResult {
  const ServerReachable();
}

class ServerNotTalePuff extends ServerCheckResult {
  const ServerNotTalePuff();
}

class ServerUnreachable extends ServerCheckResult {
  const ServerUnreachable();
}

abstract class ServerChecker {
  Future<ServerCheckResult> check(String baseUrl);
}

class ServerCheckService implements ServerChecker {
  ServerCheckService({http.Client? client, Duration timeout = const Duration(seconds: 5)})
      : _client = client ?? http.Client(),
        _timeout = timeout;

  final http.Client _client;
  final Duration _timeout;

  @override
  Future<ServerCheckResult> check(String baseUrl) async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/api/health')).timeout(_timeout);
      if (response.statusCode != 200) return const ServerNotTalePuff();
      final body = jsonDecode(response.body);
      return body is Map && body['service'] == 'talepuff' ? const ServerReachable() : const ServerNotTalePuff();
    } on TimeoutException {
      return const ServerUnreachable();
    } on SocketException {
      return const ServerUnreachable();
    } on http.ClientException {
      return const ServerUnreachable();
    } on FormatException {
      return const ServerNotTalePuff();
    }
  }
}
