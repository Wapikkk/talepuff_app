import 'package:flutter_test/flutter_test.dart';
import 'package:talepuff_app/core/validators.dart';

void main() {
  group('AuthValidators.email', () {
    test('accepts common and long-TLD addresses', () {
      for (final email in ['a@b.co', 'parent.name+tag@mail.example.com', 'x@site.technology', '  a@b.co  ']) {
        expect(AuthValidators.email(email), isNull, reason: email);
      }
    });

    test('rejects malformed addresses', () {
      for (final email in ['', '   ', 'plain', 'a@b', '@b.com', 'a@.com', 'a b@c.com']) {
        expect(AuthValidators.email(email), isNotNull, reason: email);
      }
    });
  });

  group('AuthValidators.newPassword', () {
    test('accepts letters+digits, including symbols (the old rule rejected them)', () {
      for (final password in ['abcd1234', 'Pass@1234', 'my pass 99', 'Zz9!Zz9!']) {
        expect(AuthValidators.newPassword(password), isNull, reason: password);
      }
    });

    test('rejects short, letter-only, digit-only and empty passwords', () {
      for (final password in ['', 'abc123', 'abcdefgh', '12345678', '!!!!!!!!']) {
        expect(AuthValidators.newPassword(password), isNotNull, reason: password);
      }
    });

    test('the message states the real requirement', () {
      expect(AuthValidators.newPassword('abc'), contains('8 characters'));
    });
  });
}
