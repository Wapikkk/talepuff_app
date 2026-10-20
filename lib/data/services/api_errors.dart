import 'dart:convert';
import 'package:http/http.dart' as http;

const outdatedBackendMessage =
    "The server doesn't support this action yet. Please restart the backend so it runs the latest version.";

bool isMissingEndpoint(http.Response response) {
  if (response.statusCode != 404) return false;
  try {
    final body = jsonDecode(response.body);
    return !(body is Map && body.containsKey('error'));
  } catch (_) {
    return true;
  }
}
