enum StoryTab {
  recent,
  favorites,
  popular;

  String get apiValue => name;
}

class StorySummary {
  final int id;
  final int childId;
  final String title;
  final String theme;
  final String mood;
  final String language;
  final int lengthMinutes;
  final String audioUrl;
  final String voiceTone;
  final bool isFavorite;
  final int playCount;
  final DateTime createdAt;

  const StorySummary({
    required this.id,
    required this.childId,
    required this.title,
    required this.theme,
    required this.mood,
    required this.language,
    required this.lengthMinutes,
    required this.audioUrl,
    required this.voiceTone,
    required this.isFavorite,
    required this.playCount,
    required this.createdAt,
  });

  factory StorySummary.fromJson(Map<String, dynamic> json) => StorySummary._parse(json);

  static StorySummary _parse(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is num ? rawId.toInt() : int.tryParse('$rawId');
    if (id == null || id <= 0) throw const FormatException('Story has no id');

    final rawChild = json['child_id'];
    final rawLength = json['length_minutes'];
    final rawPlays = json['play_count'];
    return StorySummary(
      id: id,
      childId: rawChild is num ? rawChild.toInt() : 0,
      title: json['title']?.toString() ?? '',
      theme: json['theme']?.toString() ?? '',
      mood: json['mood']?.toString() ?? '',
      language: json['language']?.toString() ?? '',
      lengthMinutes: rawLength is num ? rawLength.toInt() : 0,
      audioUrl: json['audio_url']?.toString() ?? '',
      voiceTone: json['voice_tone']?.toString() ?? '',
      isFavorite: json['is_favorite'] == true,
      playCount: rawPlays is num ? rawPlays.toInt() : 0,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  bool get hasAudio => audioUrl.isNotEmpty;

  List<String> get moods => mood.split(',').map((m) => m.trim()).where((m) => m.isNotEmpty).toList();

  StorySummary copyWith({bool? isFavorite}) => StorySummary(
        id: id,
        childId: childId,
        title: title,
        theme: theme,
        mood: mood,
        language: language,
        lengthMinutes: lengthMinutes,
        audioUrl: audioUrl,
        voiceTone: voiceTone,
        isFavorite: isFavorite ?? this.isFavorite,
        playCount: playCount,
        createdAt: createdAt,
      );
}

/// Satu kalimat yang dibacakan, dengan waktu dalam milidetik dari awal audio.
class StorySentence {
  final int startMs;
  final int endMs;
  final String text;
  const StorySentence(this.startMs, this.endMs, this.text);

  static List<StorySentence> parseAll(Object? raw) {
    if (raw is! List) return const [];
    final result = <StorySentence>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final start = item['start'];
      final end = item['end'];
      final text = item['text']?.toString().trim() ?? '';
      if (start is num && end is num && text.isNotEmpty) {
        result.add(StorySentence(start.toInt(), end.toInt(), text));
      }
    }
    return result;
  }

  /// Kalimat yang sedang dibacakan pada [ms]. Di jeda antar kalimat tetap kalimat sebelumnya;
  /// sebelum yang pertama dimulai, kalimat pertama.
  static StorySentence? at(List<StorySentence> sentences, int ms) {
    if (sentences.isEmpty) return null;
    var current = sentences.first;
    for (final sentence in sentences) {
      if (sentence.startMs > ms) break;
      current = sentence;
    }
    return current;
  }
}

class StoryDetail extends StorySummary {
  final String content;
  final String description;
  final List<StorySentence> sentences;

  const StoryDetail({
    required super.id,
    required super.childId,
    required super.title,
    required super.theme,
    required super.mood,
    required super.language,
    required super.lengthMinutes,
    required super.audioUrl,
    required super.voiceTone,
    required super.isFavorite,
    required super.playCount,
    required super.createdAt,
    required this.content,
    required this.description,
    this.sentences = const [],
  });

  factory StoryDetail.fromJson(Map<String, dynamic> json) {
    final base = StorySummary.fromJson(json);
    return StoryDetail(
      id: base.id,
      childId: base.childId,
      title: base.title,
      theme: base.theme,
      mood: base.mood,
      language: base.language,
      lengthMinutes: base.lengthMinutes,
      audioUrl: base.audioUrl,
      voiceTone: base.voiceTone,
      isFavorite: base.isFavorite,
      playCount: base.playCount,
      createdAt: base.createdAt,
      content: json['content']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      sentences: StorySentence.parseAll(json['sentences']),
    );
  }

  @override
  StoryDetail copyWith({bool? isFavorite}) => StoryDetail(
        id: id,
        childId: childId,
        title: title,
        theme: theme,
        mood: mood,
        language: language,
        lengthMinutes: lengthMinutes,
        audioUrl: audioUrl,
        voiceTone: voiceTone,
        isFavorite: isFavorite ?? this.isFavorite,
        playCount: playCount,
        createdAt: createdAt,
        content: content,
        description: description,
        sentences: sentences,
      );
}

class StoryPage {
  final List<StorySummary> stories;
  final bool hasMore;
  const StoryPage(this.stories, {required this.hasMore});
}
