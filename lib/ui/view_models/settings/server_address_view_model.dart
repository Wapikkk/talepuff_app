import 'package:flutter/material.dart';

import '../../../core/server_address.dart';
import '../../../data/models/app_message.dart';
import '../../../data/services/server_check_service.dart';

enum ServerSaveOutcome { saved, invalid }

class ServerAddressViewModel extends ChangeNotifier {
  ServerAddressViewModel({required ServerChecker checker}) : _checker = checker;

  final ServerChecker _checker;

  bool _isChecking = false;
  AppMessage? _error;
  bool _disposed = false;

  bool get isChecking => _isChecking;
  AppMessage? get error => _error;

  void clearError() {
    if (_error == null) return;
    _error = null;
    _notify();
  }

  Future<String?> check(String input) async {
    if (_isChecking) return null;

    final parsed = ServerAddress.parse(input);
    if (parsed is InvalidServerAddress) {
      _error = parsed.message;
      _notify();
      return null;
    }
    final url = (parsed as ValidServerAddress).url;

    _isChecking = true;
    _error = null;
    _notify();

    final result = await _checker.check(url);
    _isChecking = false;
    switch (result) {
      case ServerReachable():
        _error = null;
        _notify();
        return url;
      case ServerNotTalePuff():
        _error = AppMessage.addressNotTalepuff;
      case ServerUnreachable():
        _error = AppMessage.addressUnreachable;
    }
    _notify();
    return null;
  }

  Future<ServerSaveOutcome> save(String input) async {
    final parsed = ServerAddress.parse(input);
    if (parsed is InvalidServerAddress) {
      _error = parsed.message;
      _notify();
      return ServerSaveOutcome.invalid;
    }
    await ServerAddress.save((parsed as ValidServerAddress).url);
    _error = null;
    _notify();
    return ServerSaveOutcome.saved;
  }

  Future<void> useDefault() async {
    await ServerAddress.reset();
    _error = null;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
