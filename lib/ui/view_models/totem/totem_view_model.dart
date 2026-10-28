import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/models/account_result.dart';
import '../../../data/models/app_message.dart';
import '../../../data/models/totem.dart';
import '../../../data/repositories/totem_repository.dart';

class TotemViewModel extends ChangeNotifier {
  TotemViewModel({required TotemRepository repository, Duration pollInterval = const Duration(seconds: 2)})
      : _repository = repository,
        _pollInterval = pollInterval;

  final TotemRepository _repository;
  final Duration _pollInterval;

  TotemInfo? _info;
  AppMessage? _error;
  bool _isBusy = false;
  bool _refreshing = false;
  bool _disposed = false;
  int _watchers = 0;
  Timer? _timer;

  TotemInfo? get info => _info;
  AppMessage? get error => _error;
  bool get isBusy => _isBusy;
  bool get isLoaded => _info != null;
  bool get isPaired => _info?.paired == true;
  String? get deviceId => _info?.deviceId;
  TotemStatus get status => _info?.status ?? const TotemStatus();

  /// Layar yang butuh status terbaru memanggil [watch] saat tampil dan [unwatch] saat ditutup;
  /// polling hanya berjalan selama ada yang menonton.
  void watch() {
    _watchers++;
    if (_watchers != 1) return;
    refresh();
    _timer = Timer.periodic(_pollInterval, (_) => refresh());
  }

  void unwatch() {
    if (_watchers > 0) _watchers--;
    if (_watchers == 0) {
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> refresh() async {
    if (_refreshing || _disposed) return;
    _refreshing = true;
    final result = await _repository.info();
    _refreshing = false;
    if (_disposed) return;
    switch (result) {
      case TotemInfoLoaded(:final info):
        _info = info;
        _error = null;
      case TotemInfoFailed(:final message):
        _error = message;
    }
    notifyListeners();
  }

  /// Dipanggil saat keluar akun agar totem akun sebelumnya tidak terlihat oleh akun berikutnya.
  void reset() {
    _info = null;
    _error = null;
    notifyListeners();
  }

  Future<AccountResult?> pair(String deviceId) => _act(() => _repository.pair(deviceId));
  Future<AccountResult?> unpair() => _act(_repository.unpair);
  Future<AccountResult?> play(int storyId) => _act(() => _repository.play(storyId));
  Future<AccountResult?> pause() => _act(_repository.pause);
  Future<AccountResult?> resume() => _act(_repository.resume);
  Future<AccountResult?> stop() => _act(_repository.stop);
  Future<AccountResult?> setVolume(int value) => _act(() => _repository.setVolume(value));

  Future<AccountResult?> _act(Future<AccountResult> Function() action) async {
    if (_isBusy) return null;
    _isBusy = true;
    notifyListeners();
    try {
      final result = await action();
      if (result is AccountSuccess && !_disposed) await refresh();
      return result;
    } finally {
      _isBusy = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
