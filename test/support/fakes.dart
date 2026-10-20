import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:talepuff_app/data/models/child_profile.dart';
import 'package:talepuff_app/data/repositories/account_repository.dart';
import 'package:talepuff_app/data/repositories/auth_repository.dart';
import 'package:talepuff_app/data/services/auth_gateway.dart';
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
  Future<AuthUser> signUpWithEmail(String email, String password) => _run('signUp:$email');

  @override
  Future<AuthUser> signInWithEmail(String email, String password) => _run('signIn:$email');

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
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    calls.add('changePassword:$currentPassword->$newPassword');
    await gate?.future;
    if (failure != null) throw failure!;
  }

  @override
  Future<void> requestEmailChange({required String currentPassword, required String newEmail}) async {
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
  final renamed = <String>[];
  final registered = <ChildDraft>[];
  int fetchCalls = 0;
  int _nextId = 1;

  @override
  Future<ProfileLookup> fetchProfile(String firebaseUid) async {
    fetchCalls++;
    if (forcedLookup != null) return forcedLookup!;
    final profile = store[firebaseUid];
    return profile == null ? const ProfileNotFound() : ProfileFound(profile, const {});
  }

  @override
  Future<void> updateChildName({required int childId, required String name}) async {
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
  AuthFixture({AuthUser? signedInUser}) : gateway = FakeGateway(user: signedInUser) {
    repository = AuthRepository(gateway: gateway, api: api, session: session);
  }

  final FakeGateway gateway;
  final api = FakeProfileApi();
  final session = FakeSessionStore();
  late final AuthRepository repository;

  ChildProfile seedProfile({String uid = 'uid-1', String name = 'Aira', int id = 7}) {
    final profile = ChildProfile(id: id, name: name, age: 3, gender: 'Girl', interests: const ['Space']);
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
  FakeAppInfo({this.label = '1.0.0 (1)', this.code = '1.0.0+1', this.fails = false});

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
  Future<void> send({required String category, required String message, required String appVersion}) async {
    if (error != null) throw error!;
    sent.add({'category': category, 'message': message, 'version': appVersion});
  }
}

/// Klien HTTP untuk tes yang tidak boleh menyentuh jaringan: memakainya akan menggagalkan tes.
http.Client unusedHttpClient() => MockClient((_) async => throw StateError('network is not expected in this test'));
