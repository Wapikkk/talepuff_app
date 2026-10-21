import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

sealed class ServerAddressResult {
  const ServerAddressResult();
}

class ValidServerAddress extends ServerAddressResult {
  final String url;
  const ValidServerAddress(this.url);
}

class InvalidServerAddress extends ServerAddressResult {
  final String message;
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
    if (text.isEmpty) return const InvalidServerAddress('Enter the address of your computer, like 192.168.1.5:8080.');

    if (!text.contains('://')) text = 'http://$text';
    final uri = Uri.tryParse(text);
    if (uri == null || uri.host.isEmpty) {
      return const InvalidServerAddress("That doesn't look like an address. Try something like 192.168.1.5:8080.");
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return const InvalidServerAddress('The address must start with http:// or https://.');
    }
    if ((uri.path.isNotEmpty && uri.path != '/') || uri.hasQuery || uri.hasFragment || uri.userInfo.isNotEmpty) {
      return const InvalidServerAddress('Enter only the address and port, like 192.168.1.5:8080.');
    }
    if (!_isLocalNetwork(uri.host)) {
      return const InvalidServerAddress(
        "Use your computer's address on the same Wi-Fi (like 192.168.1.5), not an internet address.",
      );
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
