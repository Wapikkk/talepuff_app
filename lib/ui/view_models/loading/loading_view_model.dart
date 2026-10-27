import 'dart:async';
import 'package:flutter/material.dart';
import '../../../data/models/app_message.dart';
import '../../../data/models/story.dart';
import '../../../data/models/story_job.dart';
import '../../../data/repositories/story_repository.dart';

enum LoadingStage { starting, writing, voice, done, failed }

class LoadingViewModel extends ChangeNotifier {
  LoadingViewModel({
    required StoryRepository repository,
    Duration pollInterval = const Duration(seconds: 2),
    int maxPollFailures = 5,
  })  : _repository = repository,
        _pollInterval = pollInterval,
        _maxPollFailures = maxPollFailures;

  final StoryRepository _repository;
  final Duration _pollInterval;
  final int _maxPollFailures;

  LoadingStage _stage = LoadingStage.starting;
  AppMessage? _failure;
  StoryDetail? _story;
  bool _ideaDropped = false;
  bool _nameReplaced = false;
  bool _canRetry = true;

  int _currentMascotIndex = 0;
  Timer? _sliderTimer;

  int _run = 0;
  Timer? _timer;
  bool _disposed = false;

  LoadingStage get stage => _stage;
  AppMessage? get failure => _failure;
  StoryDetail? get story => _story;
  bool get ideaDropped => _ideaDropped;
  bool get nameReplaced => _nameReplaced;

  AppMessage? get notice {
    if (_ideaDropped && _nameReplaced) return AppMessage.noticeBothReplaced;
    if (_nameReplaced) return AppMessage.noticeNameReplaced;
    if (_ideaDropped) return AppMessage.noticeIdeaDropped;
    return null;
  }
  bool get canRetry => _canRetry;
  bool get isWorking => _stage == LoadingStage.starting || _stage == LoadingStage.writing || _stage == LoadingStage.voice;
  bool get storyWasSaved => _stage == LoadingStage.failed && _story != null;

  int get currentMascotIndex => _currentMascotIndex;

  int get step => switch (_stage) {
        LoadingStage.starting => 0,
        LoadingStage.writing => 1,
        LoadingStage.voice => 2,
        _ => 0,
      };

  void startAutoplay(PageController controller, int itemCount) {
    _sliderTimer?.cancel();
    _sliderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (controller.hasClients) {
        controller.animateToPage(
          (_currentMascotIndex + 1) % itemCount,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  void updateMascotIndex(int index) {
    _currentMascotIndex = index;
    _notify();
  }

  Future<void> start(Map<String, dynamic> payload, {VoidCallback? onCreated}) async {
    final run = ++_run;
    _timer?.cancel();
    _stage = LoadingStage.starting;
    _failure = null;
    _story = null;
    _ideaDropped = false;
    _nameReplaced = false;
    _canRetry = true;
    _notify();

    final started = await _repository.startJob(payload);
    if (_stale(run)) return;

    switch (started) {
      case JobStartFailed(:final message):
        _fail(message);
        return;
      case JobStarted(:final jobId):
        onCreated?.call();
        await _poll(run, jobId);
    }
  }

  Future<void> _poll(int run, int jobId) async {
    var failures = 0;
    var first = true;
    while (!_stale(run)) {
      if (!first) await _wait(_pollInterval);
      first = false;
      if (_stale(run)) return;

      final result = await _repository.checkJob(jobId);
      if (_stale(run)) return;

      switch (result) {
        case JobChecked(:final job):
          failures = 0;
          _apply(job);
          if (job.status.isFinished) return;
        case JobCheckFailed():
          failures++;
          if (failures >= _maxPollFailures) {
            _fail(AppMessage.connectionLost);
            return;
          }
      }
    }
  }

  void _apply(StoryJob job) {
    _story = job.story ?? _story;
    _ideaDropped = job.ideaDropped;
    _nameReplaced = job.nameReplaced;
    switch (job.status) {
      case StoryJobStatus.queued:
        _stage = LoadingStage.starting;
      case StoryJobStatus.writingStory:
        _stage = LoadingStage.writing;
      case StoryJobStatus.creatingVoice:
        _stage = LoadingStage.voice;
      case StoryJobStatus.done:
        _stage = LoadingStage.done;
      case StoryJobStatus.failed:
        _canRetry = job.errorCode != 'voice_failed';
        _fail(StoryRepository.jobFailure(job));
        return;
    }
    _notify();
  }

  void _fail(AppMessage message) {
    _stage = LoadingStage.failed;
    _failure = message;
    _notify();
  }

  Future<void> _wait(Duration duration) {
    final completer = Completer<void>();
    _timer = Timer(duration, completer.complete);
    return completer.future;
  }

  bool _stale(int run) => _disposed || run != _run;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    _sliderTimer?.cancel();
    super.dispose();
  }
}
