import 'package:kylie_gym/src/features/settings/presentation/widgets/dialogs/branch_form_dialog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('branchNameValidator', () {
    test('rejects empty values', () {
      final validator = branchNameValidator();
      expect(validator(null), isNotNull);
      expect(validator(''), isNotNull);
      expect(validator('Bacolod Branch'), isNull);
    });
  });

  group('branchCodeValidator', () {
    test('rejects empty values', () {
      final validator = branchCodeValidator();
      expect(validator(null), isNotNull);
      expect(validator(''), isNotNull);
    });

    test('rejects codes longer than 5 characters', () {
      final validator = branchCodeValidator();
      expect(validator('ABCDEF'), isNotNull);
    });

    test('rejects non-alphanumeric codes', () {
      final validator = branchCodeValidator();
      expect(validator('BC-D'), isNotNull);
      expect(validator('BC D'), isNotNull);
    });

    test('accepts valid short alphanumeric codes', () {
      final validator = branchCodeValidator();
      expect(validator('BCD'), isNull);
      expect(validator('TAL1'), isNull);
      expect(validator('a1'), isNull);
    });
  });
}
