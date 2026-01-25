import 'package:flutter_test/flutter_test.dart';
import 'package:komiut/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('returns error when email is null', () {
        expect(Validators.validateEmail(null), 'Email is required');
      });

      test('returns error when email is empty', () {
        expect(Validators.validateEmail(''), 'Email is required');
      });

      test('returns error for invalid email format - no @', () {
        expect(Validators.validateEmail('testexample.com'), 'Please enter a valid email');
      });

      test('returns error for invalid email format - no domain', () {
        expect(Validators.validateEmail('test@'), 'Please enter a valid email');
      });

      test('returns error for invalid email format - no TLD', () {
        expect(Validators.validateEmail('test@example'), 'Please enter a valid email');
      });

      test('returns null for valid email', () {
        expect(Validators.validateEmail('test@example.com'), isNull);
      });

      test('returns null for valid email with subdomain', () {
        expect(Validators.validateEmail('test@mail.example.com'), isNull);
      });

      test('returns null for valid email with plus sign', () {
        expect(Validators.validateEmail('test+tag@example.com'), isNull);
      });
    });

    group('validatePassword', () {
      test('returns error when password is null', () {
        expect(Validators.validatePassword(null), 'Password is required');
      });

      test('returns error when password is empty', () {
        expect(Validators.validatePassword(''), 'Password is required');
      });

      test('returns error when password is too short', () {
        expect(
          Validators.validatePassword('Ab1'),
          'Password must be at least 8 characters',
        );
      });

      test('returns error when password has no uppercase', () {
        expect(
          Validators.validatePassword('password123'),
          'Password must contain uppercase, lowercase, and number',
        );
      });

      test('returns error when password has no lowercase', () {
        expect(
          Validators.validatePassword('PASSWORD123'),
          'Password must contain uppercase, lowercase, and number',
        );
      });

      test('returns error when password has no number', () {
        expect(
          Validators.validatePassword('PasswordABC'),
          'Password must contain uppercase, lowercase, and number',
        );
      });

      test('returns null for valid password', () {
        expect(Validators.validatePassword('Password123'), isNull);
      });

      test('returns null for valid password with special chars', () {
        expect(Validators.validatePassword('Password123!@#'), isNull);
      });
    });

    group('validateConfirmPassword', () {
      test('returns error when confirm password is null', () {
        expect(
          Validators.validateConfirmPassword(null, 'Password123'),
          'Please confirm your password',
        );
      });

      test('returns error when confirm password is empty', () {
        expect(
          Validators.validateConfirmPassword('', 'Password123'),
          'Please confirm your password',
        );
      });

      test('returns error when passwords do not match', () {
        expect(
          Validators.validateConfirmPassword('Password456', 'Password123'),
          'Passwords do not match',
        );
      });

      test('returns null when passwords match', () {
        expect(
          Validators.validateConfirmPassword('Password123', 'Password123'),
          isNull,
        );
      });
    });

    group('validateFullName', () {
      test('returns error when name is null', () {
        expect(Validators.validateFullName(null), 'Full name is required');
      });

      test('returns error when name is empty', () {
        expect(Validators.validateFullName(''), 'Full name is required');
      });

      test('returns error when name is too short', () {
        expect(Validators.validateFullName('A'), 'Please enter a valid name');
      });

      test('returns error when name has only one word', () {
        expect(
          Validators.validateFullName('John'),
          'Please enter your full name',
        );
      });

      test('returns null for valid full name', () {
        expect(Validators.validateFullName('John Doe'), isNull);
      });

      test('returns null for name with multiple words', () {
        expect(Validators.validateFullName('John Michael Doe'), isNull);
      });

      test('handles extra whitespace', () {
        expect(Validators.validateFullName('  John   Doe  '), isNull);
      });
    });

    group('validateOtp', () {
      test('returns error when OTP is null', () {
        expect(Validators.validateOtp(null), 'OTP is required');
      });

      test('returns error when OTP is empty', () {
        expect(Validators.validateOtp(''), 'OTP is required');
      });

      test('returns error when OTP is too short', () {
        expect(Validators.validateOtp('123'), 'OTP must be 6 digits');
      });

      test('returns error when OTP is too long', () {
        expect(Validators.validateOtp('1234567'), 'OTP must be 6 digits');
      });

      test('returns error when OTP contains non-numeric characters', () {
        expect(Validators.validateOtp('12345a'), 'OTP must contain only numbers');
      });

      test('returns null for valid OTP', () {
        expect(Validators.validateOtp('123456'), isNull);
      });
    });

    group('validateAmount', () {
      test('returns error when amount is null', () {
        expect(Validators.validateAmount(null), 'Amount is required');
      });

      test('returns error when amount is empty', () {
        expect(Validators.validateAmount(''), 'Amount is required');
      });

      test('returns error when amount is not a number', () {
        expect(Validators.validateAmount('abc'), 'Please enter a valid amount');
      });

      test('returns error when amount is zero', () {
        expect(Validators.validateAmount('0'), 'Amount must be greater than 0');
      });

      test('returns error when amount is negative', () {
        expect(Validators.validateAmount('-100'), 'Amount must be greater than 0');
      });

      test('returns null for valid integer amount', () {
        expect(Validators.validateAmount('100'), isNull);
      });

      test('returns null for valid decimal amount', () {
        expect(Validators.validateAmount('100.50'), isNull);
      });
    });

    group('validateRequired', () {
      test('returns error when value is null', () {
        expect(
          Validators.validateRequired(null, 'Field'),
          'Field is required',
        );
      });

      test('returns error when value is empty', () {
        expect(
          Validators.validateRequired('', 'Field'),
          'Field is required',
        );
      });

      test('returns null when value is provided', () {
        expect(Validators.validateRequired('value', 'Field'), isNull);
      });
    });
  });
}
