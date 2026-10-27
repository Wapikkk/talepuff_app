import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/app_message.dart';

sealed class ServerAddressResult {
  const ServerAddressResult();
}

class ValidServerAddress extends ServerAddressResult {
  final String url;
  const ValidServerAddress(this.url);
}

class InvalidServerAddress extends ServerAddressResult {
  final AppMessage message;
  const InvalidServerAddress(this.message);
}

class ServerAddress {
  ServerAddress._();

  static const String _prefsKey = 'server_base_url';
  static const int defaultPort = 8080;

  static String? _saved;

  static String get defaultUrl => (dotenv.maybeGet('API_BASE_URL') ?? '').trim();

  static String get baseUrl => _saved ?? defaultUrl;

  static bool get isCustom => _saved != null;

  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefsKey);
      _saved = stored != null && parse(stored) is ValidServerAddress ? stored : null;
    } catch (_) {
      _saved = null;
    }
  }

  static Future<void> save(String url) async {
    _saved = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, url);
  }

  static Future<void> reset() async {
    _saved = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  static void forgetForTest() => _saved = null;

  static ServerAddressResult parse(String input) {
    var text = input.trim();
    if (text.isEmpty) return const InvalidServerAddress(AppMessage.addressRequired);

    if (!text.contains('://')) text = 'http://$text';
    final uri = Uri.tryParse(text);
    if (uri == null || uri.host.isEmpty) {
      return const InvalidServerAddress(AppMessage.addressInvalid);
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return const InvalidServerAddress(AppMessage.addressBadScheme);
    }
    if ((uri.path.isNotEmpty && uri.path != '/') || uri.hasQuery || uri.hasFragment || uri.userInfo.isNotEmpty) {
      return const InvalidServerAddress(AppMessage.addressExtraParts);
    }
    if (!_isLocalNetwork(uri.host)) {
      return const InvalidServerAddress(AppMessage.addressNotLocal);
    }

    final port = uri.hasPort ? uri.port : defaultPort;
    return ValidServerAddress('${uri.scheme}://${uri.host}:$port');
  }

  static bool _isLocalNetwork(String host) {
    final lower = host.toLowerCase();
    if (lower == 'localhost' || lower.endsWith('.local')) return true;

    final parts = lower.split('.');
    if (parts.length != 4) return false;
    final octets = parts.map(int.tryParse).toList();
    if (octets.any((o) => o == null || o < 0 || o > 255)) return false;

    final a = octets[0]!, b = octets[1]!;
    return a == 10 || a == 127 || (a == 172 && b >= 16 && b <= 31) || (a == 192 && b == 168) || (a == 169 && b == 254);
  }
}
