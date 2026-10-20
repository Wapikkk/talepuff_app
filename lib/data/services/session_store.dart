import 'package:shared_preferences/shared_preferences.dart';

/// Penyimpanan lokal anak yang sedang aktif. Kunci `active_child_id` dibaca CreateStoryViewModel.
abstract class SessionStore {
  Future<void> saveActiveChildId(int id);
  Future<void> clear();
}

class SharedPrefsSessionStore implements SessionStore {
  static const activeChildKey = 'active_child_id';

  @override
  Future<void> saveActiveChildId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(activeChildKey, id);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(activeChildKey);
  }
}
