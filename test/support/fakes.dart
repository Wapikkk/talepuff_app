import 'dart:async';

import 'package:talepuff_app/data/models/child_profile.dart';
import 'package:talepuff_app/data/repositories/auth_repository.dart';
import 'package:talepuff_app/data/services/auth_gateway.dart';
import 'package:talepuff_app/data/services/auth_service.dart';
import 'package:talepuff_app/data/services/session_store.dart';

/// Pengganti Firebase/Google: hasil diatur lewat field, semua panggilan dicatat.
class FakeGateway implements AuthGateway {
  FakeGateway({this.user});

  AuthUser? user;
  AuthUser next = const AuthUser('uid-1', 'parent@example.com');
  AuthFailure? failure; // dilempar oleh setiap panggilan masuk/daftar bila diisi
  Completer<void>? gate; // bila diisi, panggilan menunggu sampai gate selesai
  final calls = <String>[];
  int signOutCalls = 0;

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

  Future<AuthUser> _run(String call) async {
    calls.add(call);
    await gate?.future;
    if (failure != null) throw failure!;
    return user = next;
  }
}

/// Pengganti backend profil anak. Menyimpan profil di memori per uid.
class FakeProfileApi implements ProfileApi {
  final Map<String, ChildProfile> store = {};
  ProfileLookup? forcedLookup; // mengesampingkan isi [store]
  ProfileApiException? registerError;
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

/// Paket lengkap untuk tes repository dan ViewModel.
class AuthFixture {
  AuthFixture({AuthUser? signedInUser}) : gateway = FakeGateway(user: signedInUser) {
    repository = AuthRepository(gateway: gateway, api: api, session: session);
  }

  final FakeGateway gateway;
  final api = FakeProfileApi();
  final session = FakeSessionStore();
  late final AuthRepository repository;

  /// Menyiapkan profil yang sudah tersimpan di backend untuk [uid].
  ChildProfile seedProfile({String uid = 'uid-1', String name = 'Aira', int id = 7}) {
    final profile = ChildProfile(id: id, name: name, age: 3, gender: 'Girl', interests: const ['Space']);
    api.store[uid] = profile;
    return profile;
  }
}

const childDraft = ChildDraft(
  name: 'Aira',
  age: 3,
  gender: 'Girl',
  interests: ['Space', 'Music'],
);
