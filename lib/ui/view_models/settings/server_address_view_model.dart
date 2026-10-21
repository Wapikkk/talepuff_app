import 'package:flutter/material.dart';

import '../../../core/server_address.dart';
import '../../../data/services/server_check_service.dart';

enum ServerSaveOutcome { saved, invalid }

class ServerAddressViewModel extends ChangeNotifier {
  ServerAddressViewModel({required ServerChecker checker}) : _checker = checker;

  final ServerChecker _checker;

  bool _isChecking = false;
  String? _errorMessage;
  bool _disposed = false;

  bool get isChecking => _isChecking;
  String? get errorMessage => _errorMessage;

  void clearError() {
    if (_errorMessage == null) return;
    _errorMessage = null;
    _notify();
  }

  Future<String?> check(String input) async {
    if (_isChecking) return null;

    final parsed = ServerAddress.parse(input);
    if (parsed is InvalidServerAddress) {
      _errorMessage = parsed.message;
      _notify();
      return null;
    }
    final url = (parsed as ValidServerAddress).url;

    _isChecking = true;
    _errorMessage = null;
    _notify();

    final result = await _checker.check(url);
    _isChecking = false;
    switch (result) {
      case ServerReachable():
        _errorMessage = null;
        _notify();
        return url;
      case ServerNotTalePuff():
        _errorMessage = 'We reached a server there, but it is not the TalePuff backend, or it needs a restart.';
      case ServerUnreachable():
        _errorMessage = "Can't reach that address. Check that the backend is running and your phone is on the same Wi-Fi.";
    }
    _notify();
    return null;
  }

  Future<ServerSaveOutcome> save(String input) async {
    final parsed = ServerAddress.parse(input);
    if (parsed is InvalidServerAddress) {
      _errorMessage = parsed.message;
      _notify();
      return ServerSaveOutcome.invalid;
    }
    await ServerAddress.save((parsed as ValidServerAddress).url);
    _errorMessage = null;
    _notify();
    return ServerSaveOutcome.saved;
  }

  Future<void> useDefault() async {
    await ServerAddress.reset();
    _errorMessage = null;
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
