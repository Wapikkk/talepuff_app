import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

/// Pemutar audio di HP. Antarmuka ini memisahkan paket pemutar dari sisanya, supaya tes memakai tiruan.
abstract class AudioPlayerPort {
  Stream<Duration> get positions;
  Stream<Duration> get durations;
  Stream<void> get completions;

  /// Menyiapkan audio dari [url]; melempar bila tidak bisa dijangkau atau bukan audio.
  Future<void> load(String url);
  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> stop();
  Future<void> dispose();
}

class AudioplayersPort implements AudioPlayerPort {
  AudioplayersPort() : _player = AudioPlayer();

  final AudioPlayer _player;

  @override
  Stream<Duration> get positions => _player.onPositionChanged;

  @override
  Stream<Duration> get durations => _player.onDurationChanged;

  @override
  Stream<void> get completions => _player.onPlayerComplete;

  @override
  Future<void> load(String url) => _player.setSourceUrl(url);

  @override
  Future<void> play() => _player.resume();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> dispose() => _player.dispose();
}
