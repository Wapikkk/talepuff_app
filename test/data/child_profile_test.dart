import 'package:flutter_test/flutter_test.dart';
import 'package:talepuff_app/data/models/child_profile.dart';

void main() {
  test('reads the Go-style "ID" key and snake_case fields', () {
    final profile = ChildProfile.fromJson({
      'ID': 7,
      'UserID': 3,
      'name': 'Aira',
      'age': 3,
      'gender': 'Girl',
      'interests': ['Space', 'Music'],
      'profile_photo_url': 'http://x/uploads/a.jpg',
    });

    expect(profile.id, 7);
    expect(profile.name, 'Aira');
    expect(profile.age, 3);
    expect(profile.interests, ['Space', 'Music']);
    expect(profile.photoUrl, 'http://x/uploads/a.jpg');
  });

  test('also accepts a lowercase "id"', () {
    expect(ChildProfile.fromJson({'id': 12, 'name': 'B'}).id, 12);
  });

  test('missing optional fields fall back to safe defaults', () {
    final profile = ChildProfile.fromJson({'ID': 1, 'interests': null, 'age': null, 'profile_photo_url': ''});
    expect(profile.name, '');
    expect(profile.age, isNull);
    expect(profile.interests, isEmpty);
    expect(profile.photoUrl, isNull);
  });

  test('age 0 (what the backend stores when no age was given) means "no age"', () {
    expect(ChildProfile.fromJson({'ID': 1, 'age': 0}).age, isNull);
  });

  test('a profile without an id is rejected instead of silently getting id 0', () {
    expect(() => ChildProfile.fromJson({'name': 'x'}), throwsFormatException);
  });
}
