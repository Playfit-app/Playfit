import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Password Regex Validation', () {
    final passwordRegex = RegExp(
      r"""^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[ !\"#$%&'()*+,\-.\/:;<=>?@[\\\]^_`{|}~]).{8,}$""",
    );

    group('Valid passwords', () {
      test('should accept password with all required characters', () {
        expect(passwordRegex.hasMatch('Password1!'), true);
        expect(passwordRegex.hasMatch('MyP@ssw0rd'), true);
        expect(passwordRegex.hasMatch('Str0ng#Pass'), true);
        expect(passwordRegex.hasMatch('Test1234!@#\$'), true);
      });

      test('should accept password with different special characters', () {
        expect(passwordRegex.hasMatch('Password1!'), true);
        expect(passwordRegex.hasMatch('Password1@'), true);
        expect(passwordRegex.hasMatch('Password1#'), true);
        expect(passwordRegex.hasMatch('Password1\$'), true);
        expect(passwordRegex.hasMatch('Password1%'), true);
        expect(passwordRegex.hasMatch('Password1^'), true);
        expect(passwordRegex.hasMatch('Password1&'), true);
        expect(passwordRegex.hasMatch('Password1*'), true);
        expect(passwordRegex.hasMatch('Password1('), true);
        expect(passwordRegex.hasMatch('Password1)'), true);
        expect(passwordRegex.hasMatch('Password1-'), true);
        expect(passwordRegex.hasMatch('Password1_'), true);
        expect(passwordRegex.hasMatch('Password1+'), true);
        expect(passwordRegex.hasMatch('Password1='), true);
        expect(passwordRegex.hasMatch('Password1['), true);
        expect(passwordRegex.hasMatch('Password1]'), true);
        expect(passwordRegex.hasMatch('Password1{'), true);
        expect(passwordRegex.hasMatch('Password1}'), true);
        expect(passwordRegex.hasMatch('Password1;'), true);
        expect(passwordRegex.hasMatch('Password1:'), true);
        expect(passwordRegex.hasMatch('Password1\''), true);
        expect(passwordRegex.hasMatch('Password1"'), true);
        expect(passwordRegex.hasMatch('Password1,'), true);
        expect(passwordRegex.hasMatch('Password1<'), true);
        expect(passwordRegex.hasMatch('Password1>'), true);
        expect(passwordRegex.hasMatch('Password1.'), true);
        expect(passwordRegex.hasMatch('Password1/'), true);
        expect(passwordRegex.hasMatch('Password1?'), true);
        expect(passwordRegex.hasMatch('Password1\\'), true);
        expect(passwordRegex.hasMatch('Password1|'), true);
        expect(passwordRegex.hasMatch('Password1`'), true);
        expect(passwordRegex.hasMatch('Password1~'), true);
      });

      test('should accept longer passwords', () {
        expect(passwordRegex.hasMatch('VeryLongPassword123!'), true);
        expect(passwordRegex.hasMatch('ThisIsAVerySecureP@ssw0rd2024'), true);
      });
    });

    group('Invalid passwords', () {
      test('should reject password without lowercase letter', () {
        expect(passwordRegex.hasMatch('PASSWORD1!'), false);
        expect(passwordRegex.hasMatch('TEST1234@'), false);
      });

      test('should reject password without uppercase letter', () {
        expect(passwordRegex.hasMatch('password1!'), false);
        expect(passwordRegex.hasMatch('test1234@'), false);
      });

      test('should reject password without digit', () {
        expect(passwordRegex.hasMatch('Password!'), false);
        expect(passwordRegex.hasMatch('MyPass@word'), false);
      });

      test('should reject password without special character', () {
        expect(passwordRegex.hasMatch('Password1'), false);
        expect(passwordRegex.hasMatch('MyPassword123'), false);
      });

      test('should reject password shorter than 8 characters', () {
        expect(passwordRegex.hasMatch('Pass1!'), false);
        expect(passwordRegex.hasMatch('Aa1!'), false);
        expect(passwordRegex.hasMatch('Test1@'), false);
      });

      test('should reject empty or null-like passwords', () {
        expect(passwordRegex.hasMatch(''), false);
        expect(passwordRegex.hasMatch('       '), false);
      });

      test('should reject password missing multiple requirements', () {
        expect(passwordRegex.hasMatch('password'), false);
        expect(passwordRegex.hasMatch('12345678'), false);
        expect(passwordRegex.hasMatch('!!!!!!!!'), false);
        expect(passwordRegex.hasMatch('PASSWORD'), false);
      });
    });

    group('Edge cases', () {
      test('should handle exactly 8 characters with all requirements', () {
        expect(passwordRegex.hasMatch('Passw0rd!'), true);
        expect(passwordRegex.hasMatch('Test123!'), true);
      });

      test('should handle spaces as special characters', () {
        expect(passwordRegex.hasMatch('Pass word1'), true);
        expect(passwordRegex.hasMatch('My Pass1'), true);
      });
    });
  });
}