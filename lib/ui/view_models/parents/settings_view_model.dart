import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsViewModel extends ChangeNotifier{
  double _volumeLimit = 0.5; get volumeLimit => _volumeLimit;
  static const String _volumeKey = 'volume_limit_pref';

  SettingsViewModel() {
    loadVolume();
  }

  Future<void> loadVolume() async{
    final prefs = await SharedPreferences.getInstance();
    _volumeLimit = prefs.getDouble(_volumeKey) ?? 0.5;
    notifyListeners();
  }

  Future<void> updateVolume(double value) async{
    _volumeLimit = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_volumeKey, value);
  }
}