import 'package:flutter/foundation.dart';

import '../../../data/models/app_message.dart';
import '../../../data/models/weekly_stats.dart';
import '../../../data/repositories/stats_repository.dart';

class StatsViewModel extends ChangeNotifier {
  StatsViewModel({required StatsRepository repository}) : _repository = repository;

  final StatsRepository _repository;

  WeeklyStats? _stats;
  AppMessage? _error;
  bool _isLoading = false;
  bool _disposed = false;
  int? _childId;
  int _request = 0;

  WeeklyStats? get stats => _stats;
  AppMessage? get error => _error;
  bool get isLoading => _isLoading;

  Future<void> load(String? childId) async {
    final id = int.tryParse(childId ?? '');
    if (id == null) {
      _error = AppMessage.childDataNotLoaded;
      _stats = null;
      _notify();
      return;
    }
    if (_childId != id) _stats = null;
    _childId = id;

    final request = ++_request;
    _isLoading = true;
    _error = null;
    _notify();

    final result = await _repository.weekly(id);
    if (request != _request || _disposed) return;

    _isLoading = false;
    switch (result) {
      case StatsLoaded(:final stats):
        _stats = stats;
      case StatsFailed(:final message):
        _error = message;
    }
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
