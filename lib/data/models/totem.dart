class TotemStatus {
  final bool online;
  final String state; // idle | loading | playing | paused | error | offline | unknown
  final String? reason;
  final int? storyId;
  final int position;
  final int duration;
  final int volume;

  const TotemStatus({
    this.online = false,
    this.state = 'unknown',
    this.reason,
    this.storyId,
    this.position = 0,
    this.duration = 0,
    this.volume = 0,
  });

  factory TotemStatus.fromJson(Map<String, dynamic> json) {
    int number(Object? value) => value is num ? value.toInt() : 0;
    final story = json['story_id'];
    return TotemStatus(
      online: json['online'] == true,
      state: json['state']?.toString() ?? 'unknown',
      reason: json['reason']?.toString(),
      storyId: story is num ? story.toInt() : null,
      position: number(json['position']),
      duration: number(json['duration']),
      volume: number(json['volume']),
    );
  }

  bool get isActive => state == 'loading' || state == 'playing' || state == 'paused';

  bool isPlayingStory(int id) => online && isActive && storyId == id;
}

class TotemBedtime {
  final bool enabled;
  final int hour; // 0-23, zona waktu server
  final int minute;
  const TotemBedtime({this.enabled = false, this.hour = 20, this.minute = 0});

  factory TotemBedtime.fromJson(Object? json) {
    if (json is! Map) return const TotemBedtime();
    int number(Object? value, int fallback, int max) => value is num ? value.toInt().clamp(0, max) : fallback;
    return TotemBedtime(
      enabled: json['enabled'] == true,
      hour: number(json['hour'], 20, 23),
      minute: number(json['minute'], 0, 59),
    );
  }
}

class TotemInfo {
  final bool paired;
  final String? deviceId;
  final TotemStatus status;
  final int volumeLimit; // 0-100, disimpan di backend
  final TotemBedtime bedtime;

  const TotemInfo({
    this.paired = false,
    this.deviceId,
    this.status = const TotemStatus(),
    this.volumeLimit = 50,
    this.bedtime = const TotemBedtime(),
  });

  TotemInfo copyWith({TotemStatus? status, int? volumeLimit, TotemBedtime? bedtime}) => TotemInfo(
        paired: paired,
        deviceId: deviceId,
        status: status ?? this.status,
        volumeLimit: volumeLimit ?? this.volumeLimit,
        bedtime: bedtime ?? this.bedtime,
      );

  factory TotemInfo.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    return TotemInfo(
      paired: json['paired'] == true,
      deviceId: json['device_id']?.toString(),
      status: status is Map<String, dynamic> ? TotemStatus.fromJson(status) : const TotemStatus(),
      volumeLimit: json['volume_limit'] is num ? (json['volume_limit'] as num).toInt().clamp(0, 100) : 50,
      bedtime: TotemBedtime.fromJson(json['bedtime']),
    );
  }
}
