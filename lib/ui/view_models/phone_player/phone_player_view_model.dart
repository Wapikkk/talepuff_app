import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../data/models/app_message.dart';
import '../../../data/models/story.dart';
import '../../../data/services/audio_player_port.dart';

enum PhonePlayback { idle, loading, playing, paused, error }

/// Memutar satu cerita di HP ini (tanpa totem). Hanya satu cerita pada satu waktu.
class PhonePlayerViewModel extends ChangeNotifier {
  PhonePlayerViewModel({required AudioPlayerPort player, Duration loadTimeout = const Duration(seconds: 20)})
      : _player = player,
        _loadTimeout = loadTimeout {
    _subscriptions = [
      _player.positions.listen((position) {
        if (_state == PhonePlayback.playing || _state == PhonePlayback.paused) {
          _position = position;
          _notify();
        }
      }),
      _player.durations.listen((duration) {
        _duration = duration;
        _notify();
      }),
      _player.completions.listen((_) => _finish()),
    ];
  }

  final AudioPlayerPort _player;
  final Duration _loadTimeout;
  late final List<StreamSubscription<Object?>> _subscriptions;

  PhonePlayback _state = PhonePlayback.idle;
  int? _storyId;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  AppMessage? _error;
  int _request = 0;
  bool _disposed = false;

  PhonePlayback get state => _state;
  int? get storyId => _storyId;
  Duration get position => _position;
  Duration get duration => _duration;
  AppMessage? get error => _error;

  /// Apakah [storyId] sedang dipegang pemutar ini (menyiapkan, memutar, dijeda, atau gagal)?
  bool isActive(int storyId) => _storyId == storyId && _state != PhonePlayback.idle;

  Future<void> play(StoryDetail story) async {
    final url = story.playbackUrl;
    if (url.isEmpty) {
      _fail(story.id, story.audioUrl.isEmpty ? AppMessage.storyNoVoice : AppMessage.playbackUnavailable);
      return;
    }

    final request = ++_request;
    _storyId = story.id;
    _state = PhonePlayback.loading;
    _position = Duration.zero;
    _duration = Duration.zero;
    _error = null;
    _notify();

    try {
      await _player.stop();
      await _player.load(url).timeout(_loadTimeout);
      if (request != _request) return;
      await _player.play();
      if (request != _request) return;
      _state = PhonePlayback.playing;
      _notify();
    } catch (_) {
      if (request != _request) return;
      _fail(story.id, AppMessage.audioPlaybackFailed);
    }
  }

  Future<void> toggle() async {
    try {
      if (_state == PhonePlayback.playing) {
        await _player.pause();
        _state = PhonePlayback.paused;
      } else if (_state == PhonePlayback.paused) {
        await _player.play();
        _state = PhonePlayback.playing;
      } else {
        return;
      }
      _notify();
    } catch (_) {
      _fail(_storyId, AppMessage.audioPlaybackFailed);
    }
  }

  Future<void> seek(Duration position) async {
    if (_state != PhonePlayback.playing && _state != PhonePlayback.paused) return;
    final target = _duration > Duration.zero && position > _duration ? _duration : position;
    _position = target < Duration.zero ? Duration.zero : target;
    _notify();
    try {
      await _player.seek(_position);
    } catch (_) {
      _fail(_storyId, AppMessage.audioPlaybackFailed);
    }
  }

  Future<void> stop() async {
    if (_disposed) return;
    _request++;
    _reset();
    _notify();
    try {
      await _player.stop();
    } catch (_) {}
  }

  void _finish() {
    _request++;
    _reset();
    _notify();
  }

  void _reset() {
    _state = PhonePlayback.idle;
    _storyId = null;
    _position = Duration.zero;
    _duration = Duration.zero;
    _error = null;
  }

  void _fail(int? storyId, AppMessage message) {
    _storyId = storyId;
    _state = PhonePlayback.error;
    _error = message;
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _player.dispose();
    super.dispose();
  }
}
