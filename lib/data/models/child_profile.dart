import '../../core/mascots.dart';

class ChildProfile {
  final int id;
  final String name;
  final int? age;
  final String gender;
  final List<String> interests;
  final String? photoUrl;
  final String mascotId;

  const ChildProfile({
    required this.id,
    required this.name,
    this.age,
    this.gender = '',
    this.interests = const [],
    this.photoUrl,
    this.mascotId = Mascots.defaultId,
  });

  factory ChildProfile.fromJson(Map<String, dynamic> json) {
    final rawId = json['ID'] ?? json['id'];
    final id = rawId is num ? rawId.toInt() : int.tryParse('$rawId');
    if (id == null) throw const FormatException('Child profile has no id');

    final rawAge = json['age'];
    final rawPhoto = json['profile_photo_url']?.toString();
    final rawMascot = json['mascot_id']?.toString();
    return ChildProfile(
      id: id,
      name: json['name']?.toString() ?? '',
      age: rawAge is num && rawAge > 0 ? rawAge.toInt() : null,
      gender: json['gender']?.toString() ?? '',
      interests: (json['interests'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      photoUrl: (rawPhoto == null || rawPhoto.isEmpty) ? null : rawPhoto,
      mascotId: Mascots.isValid(rawMascot ?? '') ? rawMascot! : Mascots.defaultId,
    );
  }
}

class ChildDraft {
  final String name;
  final int? age;
  final String gender;
  final List<String> interests;

  const ChildDraft({
    required this.name,
    this.age,
    required this.gender,
    required this.interests,
  });
}
