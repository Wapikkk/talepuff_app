import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/models/account_result.dart';
import '../../../data/models/app_message.dart';
import '../../../data/models/totem.dart';
import '../../../data/repositories/totem_repository.dart';

class TotemViewModel extends ChangeNotifier {
  TotemViewModel({
    required TotemRepository repository,
    Duration pollInterval = const Duration(seconds: 2),
    DateTime Function() clock = DateTime.now,
  })  : _repository = repository,
        _pollInterval = pollInterval,
        _clock = clock;

  static const int bufferLagMs = 800;

  final TotemRepository _repository;
  final Duration _pollInterval;
  final DateTime Function() _clock;
  DateTime? _statusAt;

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
  int get volumeLimit => _info?.volumeLimit ?? 50;
  TotemBedtime get bedtime => _info?.bedtime ?? const TotemBedtime();

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
        _statusAt = _clock();
        _error = null;
      case TotemInfoFailed(:final message):
        _error = message;
    }
    notifyListeners();
  }

  int get audiblePositionMs {
    final reported = status.position * 1000;
    final elapsed = status.state == 'playing' && _statusAt != null ? _clock().difference(_statusAt!).inMilliseconds : 0;
    return (reported + elapsed - bufferLagMs).clamp(0, status.duration > 0 ? status.duration * 1000 : 1 << 30);
  }

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
  Future<AccountResult?> setBedtime({required bool enabled, required int hour, required int minute}) =>
      _act(() => _repository.setBedtime(enabled: enabled, hour: hour, minute: minute));
  Future<AccountResult?> setVolumeLimit(int limit) => _act(() => _repository.setVolumeLimit(limit));

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
