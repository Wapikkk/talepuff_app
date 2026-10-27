import 'dart:convert';
import 'package:http/http.dart' as http;

bool isMissingEndpoint(http.Response response) {
  if (response.statusCode != 404) return false;
  try {
    final body = jsonDecode(response.body);
    return !(body is Map && body.containsKey('error'));
  } catch (_) {
    return true;
  }
}
