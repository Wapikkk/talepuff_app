import 'package:http/http.dart' as http;

class AuthenticatedClient extends http.BaseClient {
  AuthenticatedClient({
    required Future<String?> Function() idToken,
    required String Function() baseUrl,
    http.Client? inner,
  })  : _idToken = idToken,
        _baseUrl = baseUrl,
        _inner = inner ?? http.Client();

  final Future<String?> Function() _idToken;
  final String Function() _baseUrl;
  final http.Client _inner;

  bool _isBackend(Uri url) {
    final base = Uri.tryParse(_baseUrl());
    if (base == null || base.host.isEmpty) return false;
    return url.host == base.host && url.port == base.port;
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (_isBackend(request.url)) {
      final token = await _idToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    }
    return _inner.send(request);
  }

  @override
  void close() => _inner.close();
}
