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

class TotemInfo {
  final bool paired;
  final String? deviceId;
  final TotemStatus status;

  const TotemInfo({this.paired = false, this.deviceId, this.status = const TotemStatus()});

  factory TotemInfo.fromJson(Map<String, dynamic> json) {
    final status = json['status'];
    return TotemInfo(
      paired: json['paired'] == true,
      deviceId: json['device_id']?.toString(),
      status: status is Map<String, dynamic> ? TotemStatus.fromJson(status) : const TotemStatus(),
    );
  }
}
