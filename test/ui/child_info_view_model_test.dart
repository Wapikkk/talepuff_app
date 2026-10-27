import 'package:flutter_test/flutter_test.dart';
import 'package:talepuff_app/data/models/app_message.dart';
import 'package:talepuff_app/data/models/auth_result.dart';
import 'package:talepuff_app/data/services/auth_gateway.dart';
import 'package:talepuff_app/data/services/auth_service.dart';
import 'package:talepuff_app/ui/view_models/parents/child_info_view_model.dart';

import '../support/fakes.dart';

ChildInfoViewModel make(AuthFixture f) {
  final viewModel = ChildInfoViewModel(repository: f.repository);
  addTearDown(viewModel.dispose);
  return viewModel;
}

void fill(ChildInfoViewModel vm) => vm
  ..name = '  Aira  '
  ..age = '3'
  ..selectedGender = 'Girl'
  ..selectedInterests.add('Space');

void main() {
  group('child name rule (same as the server and the story generator)', () {
    test('a name the story would replace with "Pip" makes the form invalid', () {
      final vm = make(AuthFixture());
      fill(vm);
      expect(vm.isFormValid, isTrue);

      for (final bad in ['Aira 2', 'Aira!', '2Aira', 'A' * 31]) {
        vm.name = bad;
        expect(vm.isFormValid, isFalse, reason: bad);
        expect(vm.nameError, isNotNull, reason: bad);
      }
    });

    test('saving shows the name message instead of the generic one', () async {
      final f = AuthFixture(signedInUser: const AuthUser('uid-1', null));
      final vm = make(f);
      fill(vm);
      vm.name = 'Aira 2';

      expect(await vm.completeProfile(), isNull);
      expect(vm.error, AppMessage.childNameInvalid);
      expect(f.api.registered, isEmpty, reason: 'the server would reject it with a 400 anyway');
    });
  });

  group('form validity', () {
    test('needs a name, a gender and at least one interest', () {
      final vm = make(AuthFixture());
      expect(vm.isFormValid, isFalse);

      vm.name = 'Aira';
      vm.selectedGender = 'Girl';
      expect(vm.isFormValid, isFalse);

      vm.selectedInterests.add('Space');
      expect(vm.isFormValid, isTrue);
    });

    test('age is optional but must be a positive number when given', () {
      final vm = make(AuthFixture());
      fill(vm);

      vm.age = '';
      expect(vm.isFormValid, isTrue);
      expect(vm.ageValue, isNull);

      vm.age = 'abc';
      expect(vm.ageError, isNotNull);
      expect(vm.isFormValid, isFalse);

      vm.age = '0';
      expect(vm.isFormValid, isFalse);

      vm.age = ' 4 ';
      expect(vm.ageValue, 4);
      expect(vm.isFormValid, isTrue);
    });

    test('at most three interests can be chosen', () {
      final vm = make(AuthFixture());
      for (final interest in ['A', 'B', 'C', 'D']) {
        vm.toggleInterest(interest);
      }
      expect(vm.selectedInterests, ['A', 'B', 'C']);
    });
  });

  test('toDraft trims the name, parses the age and copies the interests', () {
    final vm = make(AuthFixture());
    fill(vm);

    final draft = vm.toDraft();

    expect(draft.name, 'Aira');
    expect(draft.age, 3);
    expect(draft.gender, 'Girl');
    expect(draft.interests, ['Space']);
    expect(() => draft.interests.add('hack'), throwsUnsupportedError);
  });

  group('completeProfile', () {
    test('an invalid form returns null, shows a message and does not call the backend', () async {
      final f = AuthFixture(signedInUser: const AuthUser('uid-1', null));
      final vm = make(f);

      expect(await vm.completeProfile(), isNull);
      expect(vm.error, AppMessage.fillMandatory);
      expect(f.api.registered, isEmpty);
    });

    test('an invalid age gets its own message', () async {
      final f = AuthFixture(signedInUser: const AuthUser('uid-1', null));
      final vm = make(f);
      fill(vm);
      vm.age = 'abc';

      expect(await vm.completeProfile(), isNull);
      expect(vm.error, AppMessage.ageInvalid);
    });

    test('a valid form registers the profile and returns SignedIn', () async {
      final f = AuthFixture(signedInUser: const AuthUser('uid-1', 'parent@example.com'));
      final vm = make(f);
      fill(vm);

      final result = await vm.completeProfile();

      expect(result, isA<SignedIn>());
      expect(f.api.registered, hasLength(1));
      expect(vm.isLoading, isFalse);
    });

    test('a backend failure is shown to the user', () async {
      final f = AuthFixture(signedInUser: const AuthUser('uid-1', null));
      f.api.forcedLookup = null;
      f.api.registerError = const ProfileApiException('down');
      final vm = make(f);
      fill(vm);

      final result = await vm.completeProfile();

      expect(result, isA<AuthFailed>());
      expect(vm.error, isNotNull);
      expect(vm.isLoading, isFalse);
    });
  });

  test('reset clears everything so the next user starts with an empty form', () {
    final vm = make(AuthFixture());
    fill(vm);

    vm.reset();

    expect(vm.name, isEmpty);
    expect(vm.age, isEmpty);
    expect(vm.selectedGender, isEmpty);
    expect(vm.selectedInterests, isEmpty);
    expect(vm.childName, 'Friend');
  });
}
