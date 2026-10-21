import 'story.dart';

enum StoryJobStatus {
  queued,
  writingStory,
  creatingVoice,
  done,
  failed;

  static StoryJobStatus parse(String raw) => switch (raw) {
        'queued' => queued,
        'writing_story' => writingStory,
        'creating_voice' => creatingVoice,
        'done' => done,
        'failed' => failed,
        _ => throw FormatException('Unknown job status: $raw'),
      };

  bool get isFinished => this == done || this == failed;
}

class StoryJob {
  final int id;
  final StoryJobStatus status;
  final StoryDetail? story;
  final String errorCode;
  final bool ideaDropped;
  final bool nameReplaced;

  const StoryJob({
    required this.id,
    required this.status,
    this.story,
    this.errorCode = '',
    this.ideaDropped = false,
    this.nameReplaced = false,
  });

  factory StoryJob.fromJson(Map<String, dynamic> json) {
    final story = json['story'];
    return StoryJob(
      id: json['id'] as int,
      status: StoryJobStatus.parse(json['status'] as String),
      story: story is Map<String, dynamic> ? StoryDetail.fromJson(story) : null,
      errorCode: json['error_code']?.toString() ?? '',
      ideaDropped: json['idea_dropped'] == true,
      nameReplaced: json['name_replaced'] == true,
    );
  }
}
