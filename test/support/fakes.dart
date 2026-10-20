import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:talepuff_app/data/models/child_profile.dart';
import 'package:talepuff_app/data/repositories/account_repository.dart';
import 'package:talepuff_app/data/repositories/auth_repository.dart';
import 'package:talepuff_app/data/services/auth_gateway.dart';
import 'package:talepuff_app/data/services/story_service.dart';
import 'package:talepuff_app/data/repositories/story_repository.dart';
import 'package:talepuff_app/data/models/story.dart';
import 'package:talepuff_app/data/services/profile_photo_service.dart';
import 'package:talepuff_app/data/repositories/profile_photo_repository.dart';
import 'package:talepuff_app/data/services/feedback_service.dart';
import 'package:talepuff_app/data/services/app_info.dart';
import 'package:talepuff_app/data/services/auth_service.dart';
import 'package:talepuff_app/data/services/session_store.dart';

class FakeGateway implements AuthGateway {
  FakeGateway({this.user});

  AuthUser? user;
  AuthUser next = const AuthUser('uid-1', 'parent@example.com');
  AuthFailure? failure;
  Completer<void>? gate;
  final calls = <String>[];
  int signOutCalls = 0;
  bool hasPassword = true;

  @override
  AuthUser? get currentUser => user;

  @override
  Future<AuthUser?> restoreUser() async => user;

  @override
  Future<AuthUser> signUpWithEmail(String email, String password) =>
      _run('signUp:$email');

  @override
  Future<AuthUser> signInWithEmail(String email, String password) =>
      _run('signIn:$email');

  @override
  Future<AuthUser> signInWithGoogle() => _run('google');

  @override
  Future<void> signOut() async {
    signOutCalls++;
    user = null;
  }

  @override
  bool get usesPassword => hasPassword;

  @override
  Future<String?> idToken() async => 'fake-token';

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    calls.add('changePassword:$currentPassword->$newPassword');
    await gate?.future;
    if (failure != null) throw failure!;
  }

  @override
  Future<void> requestEmailChange({
    required String currentPassword,
    required String newEmail,
  }) async {
    calls.add('requestEmailChange:$newEmail');
    await gate?.future;
    if (failure != null) throw failure!;
  }

  Future<AuthUser> _run(String call) async {
    calls.add(call);
    await gate?.future;
    if (failure != null) throw failure!;
    return user = next;
  }
}

class FakeProfileApi implements ProfileApi {
  final Map<String, ChildProfile> store = {};
  ProfileLookup? forcedLookup;
  ProfileApiException? registerError;
  ProfileApiException? renameError;
  ProfileApiException? mascotError;
  final renamed = <String>[];
  final mascots = <String>[];
  final registered = <ChildDraft>[];
  int fetchCalls = 0;
  int _nextId = 1;

  @override
  Future<ProfileLookup> fetchProfile(String firebaseUid) async {
    fetchCalls++;
    if (forcedLookup != null) return forcedLookup!;
    final profile = store[firebaseUid];
    return profile == null
        ? const ProfileNotFound()
        : ProfileFound(profile, const {});
  }

  @override
  Future<void> updateMascot({
    required int childId,
    required String mascotId,
  }) async {
    if (mascotError != null) throw mascotError!;
    mascots.add('$childId:$mascotId');
  }

  @override
  Future<void> updateChildName({
    required int childId,
    required String name,
  }) async {
    if (renameError != null) throw renameError!;
    renamed.add('$childId:$name');
  }

  @override
  Future<void> register({
    required String firebaseUid,
    required String email,
    required ChildDraft child,
  }) async {
    if (registerError != null) throw registerError!;
    registered.add(child);
    store[firebaseUid] = ChildProfile(
      id: _nextId++,
      name: child.name,
      age: child.age,
      gender: child.gender,
      interests: child.interests,
    );
  }
}

class FakeSessionStore implements SessionStore {
  int? activeChildId;
  int clears = 0;

  @override
  Future<void> saveActiveChildId(int id) async => activeChildId = id;

  @override
  Future<void> clear() async {
    activeChildId = null;
    clears++;
  }
}

class AuthFixture {
  AuthFixture({AuthUser? signedInUser})
    : gateway = FakeGateway(user: signedInUser) {
    repository = AuthRepository(gateway: gateway, api: api, session: session);
  }

  final FakeGateway gateway;
  final api = FakeProfileApi();
  final session = FakeSessionStore();
  late final AuthRepository repository;

  ChildProfile seedProfile({
    String uid = 'uid-1',
    String name = 'Aira',
    int id = 7,
  }) {
    final profile = ChildProfile(
      id: id,
      name: name,
      age: 3,
      gender: 'Girl',
      interests: const ['Space'],
    );
    api.store[uid] = profile;
    return profile;
  }
}

class AccountFixture {
  AccountFixture({bool hasPassword = true, String email = 'parent@example.com'})
    : gateway = FakeGateway(user: AuthUser('uid-1', email)) {
    gateway.hasPassword = hasPassword;
    repository = AccountRepository(gateway: gateway, api: api);
  }

  final FakeGateway gateway;
  final api = FakeProfileApi();
  late final AccountRepository repository;
}

const childDraft = ChildDraft(
  name: 'Aira',
  age: 3,
  gender: 'Girl',
  interests: ['Space', 'Music'],
);

/// Informasi aplikasi palsu.
class FakeAppInfo implements AppInfo {
  FakeAppInfo({
    this.label = '1.0.0 (1)',
    this.code = '1.0.0+1',
    this.fails = false,
  });

  final String label;
  final String code;
  final bool fails;

  @override
  Future<String> versionLabel() async => label;

  @override
  Future<String> versionCode() async {
    if (fails) throw StateError('plugin tidak tersedia');
    return code;
  }
}

/// API feedback palsu: mencatat kiriman, dan bisa dipaksa gagal.
class FakeFeedbackApi implements FeedbackApi {
  FeedbackApiException? error;
  final sent = <Map<String, String>>[];

  @override
  Future<void> send({
    required String category,
    required String message,
    required String appVersion,
  }) async {
    if (error != null) throw error!;
    sent.add({'category': category, 'message': message, 'version': appVersion});
  }
}

/// Klien HTTP untuk tes yang tidak boleh menyentuh jaringan: memakainya akan menggagalkan tes.
http.Client unusedHttpClient() => MockClient(
  (_) async => throw StateError('network is not expected in this test'),
);

/// API foto profil palsu: mencatat panggilan, dan bisa dipaksa gagal atau ditahan.
class FakePhotoApi implements ProfilePhotoApi {
  String uploadedUrl = '/uploads/profiles/new.jpg';
  PhotoApiException? error;
  Completer<void>? gate;
  final uploads = <String>[];
  final removals = <int>[];

  @override
  Future<String> upload({
    required int childId,
    required String filePath,
  }) async {
    await gate?.future;
    if (error != null) throw error!;
    uploads.add('$childId:$filePath');
    return uploadedUrl;
  }

  @override
  Future<void> remove({required int childId}) async {
    await gate?.future;
    if (error != null) throw error!;
    removals.add(childId);
  }
}

ProfilePhotoRepository fakePhotos([FakePhotoApi? api]) =>
    ProfilePhotoRepository(api: api ?? FakePhotoApi());

StorySummary makeStory(
  int id, {
  String? title,
  String theme = 'Daily',
  String mood = 'Calm',
  int minutes = 3,
  bool favorite = false,
  int plays = 0,
  Duration age = const Duration(minutes: 7),
  String audioUrl = '',
}) {
  return StorySummary(
    id: id,
    childId: 7,
    title: title ?? 'Story $id',
    theme: theme,
    mood: mood,
    language: 'Basic English',
    lengthMinutes: minutes,
    audioUrl: audioUrl,
    voiceTone: '',
    isFavorite: favorite,
    playCount: plays,
    createdAt: DateTime.now().subtract(age),
  );
}

StoryDetail makeDetail(
  int id, {
  String content = 'First paragraph.\n\nSecond paragraph.',
  bool favorite = false,
}) {
  final base = makeStory(id, favorite: favorite);
  return StoryDetail(
    id: base.id,
    childId: base.childId,
    title: base.title,
    theme: base.theme,
    mood: 'Calm, Brave',
    language: base.language,
    lengthMinutes: base.lengthMinutes,
    audioUrl: '',
    voiceTone: '',
    isFavorite: favorite,
    playCount: 0,
    createdAt: base.createdAt,
    content: content,
    description: 'a description',
  );
}

class StoryListCall {
  final int childId;
  final StoryTab tab;
  final String query;
  final int offset;
  const StoryListCall(this.childId, this.tab, this.query, this.offset);

  @override
  String toString() => '${tab.name}|$query|$offset';
}

/// API cerita palsu. [onList] menentukan jawaban daftar (boleh ditunda dengan Completer); sisanya mencatat panggilan.
class FakeStoryApi implements StoryApi {
  Future<StoryPage> Function(StoryListCall call)? onList;
  StoryApiException? listError;
  StoryDetail? detail;
  StoryApiException? detailError;
  StoryApiException? favoriteError;
  Completer<void>? favoriteGate;
  StoryApiException? deleteError;
  Completer<void>? deleteGate;
  final deleteCalls = <int>[];
  final listCalls = <StoryListCall>[];
  final favoriteCalls = <String>[];

  @override
  Future<StoryPage> list({
    required int childId,
    required StoryTab tab,
    String query = '',
    int offset = 0,
    int limit = StoryService.pageSize,
  }) async {
    final call = StoryListCall(childId, tab, query, offset);
    listCalls.add(call);
    if (listError != null) throw listError!;
    final handler = onList;
    return handler == null
        ? const StoryPage([], hasMore: false)
        : handler(call);
  }

  @override
  Future<StoryDetail> get(int id) async {
    if (detailError != null) throw detailError!;
    return detail ?? makeDetail(id);
  }

  @override
  Future<void> delete(int id) async {
    await deleteGate?.future;
    if (deleteError != null) throw deleteError!;
    deleteCalls.add(id);
  }

  @override
  Future<void> setFavorite(int id, bool favorite) async {
    await favoriteGate?.future;
    if (favoriteError != null) throw favoriteError!;
    favoriteCalls.add('$id:$favorite');
  }
}

StoryRepository fakeStories([FakeStoryApi? api]) =>
    StoryRepository(api: api ?? FakeStoryApi());
