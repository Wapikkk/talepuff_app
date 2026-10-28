import '../models/account_result.dart';
import '../models/app_message.dart';
import '../models/totem.dart';
import '../services/totem_service.dart';

sealed class TotemInfoResult {
  const TotemInfoResult();
}

class TotemInfoLoaded extends TotemInfoResult {
  final TotemInfo info;
  const TotemInfoLoaded(this.info);
}

class TotemInfoFailed extends TotemInfoResult {
  final AppMessage message;
  const TotemInfoFailed(this.message);
}

class TotemRepository {
  TotemRepository({required TotemApi api}) : _api = api;

  final TotemApi _api;

  // Sama dengan aturan di backend dan firmware.
  static final _deviceId = RegExp(r'^[a-z0-9][a-z0-9-]{2,31}$');

  static String normalizeId(String input) => input.trim().toLowerCase();

  Future<TotemInfoResult> info() async {
    try {
      return TotemInfoLoaded(await _api.info());
    } on TotemApiException catch (e) {
      return TotemInfoFailed(_code(e));
    }
  }

  Future<AccountResult> pair(String input) async {
    final id = normalizeId(input);
    if (!_deviceId.hasMatch(id)) return const AccountFailure(AppMessage.totemInvalidId);
    return _run(() => _api.pair(id), AccountSuccess(AppMessage.totemLinked, value: id));
  }

  Future<AccountResult> unpair() => _run(_api.unpair, const AccountSuccess(AppMessage.totemUnlinked));

  Future<AccountResult> play(int storyId, {int? volume}) =>
      _run(() => _api.play(storyId, volume: volume), const AccountSuccess(AppMessage.totemSent));

  Future<AccountResult> pause() => _command('pause');
  Future<AccountResult> resume() => _command('resume');
  Future<AccountResult> stop() => _command('stop');
  Future<AccountResult> setVolume(int value) => _command('volume', value: value.clamp(0, 100));

  Future<AccountResult> setVolumeLimit(int limit) =>
      _run(() => _api.setVolumeLimit(limit.clamp(0, 100)), const AccountSuccess(AppMessage.totemSent));

  Future<AccountResult> setBedtime({required bool enabled, required int hour, required int minute}) => _run(
        () => _api.setBedtime(enabled: enabled, hour: hour.clamp(0, 23), minute: minute.clamp(0, 59)),
        const AccountSuccess(AppMessage.totemSent),
      );

  Future<AccountResult> _command(String action, {int? value}) =>
      _run(() => _api.command(action, value: value), const AccountSuccess(AppMessage.totemSent));

  Future<AccountResult> _run(Future<void> Function() call, AccountSuccess success) async {
    try {
      await call();
      return success;
    } on TotemApiException catch (e) {
      return AccountFailure(_code(e));
    }
  }

  AppMessage _code(TotemApiException e) {
    if (e.endpointMissing) return AppMessage.backendOutdated;
    switch (e.code) {
      case 'invalid_device_id':
        return AppMessage.totemInvalidId;
      case 'totem_not_visible':
        return AppMessage.totemNotVisible;
      case 'totem_taken':
        return AppMessage.totemTaken;
      case 'totem_not_paired':
        return AppMessage.totemNotPaired;
      case 'totem_offline':
        return AppMessage.totemOffline;
      case 'totem_unreachable':
        return AppMessage.totemUnreachable;
      case 'totem_unavailable':
        return AppMessage.totemUnavailable;
      case 'story_no_voice':
        return AppMessage.storyNoVoice;
    }
    return switch (e.statusCode) {
      401 || 403 => AppMessage.reloginRequired,
      404 => AppMessage.storyNotFound,
      400 => AppMessage.requestNotUnderstood,
      _ => e.message == 'Unexpected response from the server' ? AppMessage.unreadableResponse : AppMessage.serverUnreachable,
    };
  }
}
