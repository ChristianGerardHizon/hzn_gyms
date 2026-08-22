import 'package:flutter_test/flutter_test.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:kylie_gym/src/core/utils/idempotency.dart';

void main() {
  group('generateIdempotencyKey', () {
    test('returns unique UUID-like values', () {
      final a = generateIdempotencyKey();
      final b = generateIdempotencyKey();
      expect(a, isNot(equals(b)));
      expect(a.length, greaterThanOrEqualTo(32));
    });
  });

  group('isPocketBaseUniqueViolation', () {
    test('true when field has validation_not_unique', () {
      final error = ClientException(
        url: Uri.parse('https://example.com'),
        statusCode: 400,
        response: {
          'data': {
            'idempotencyKey': {
              'code': 'validation_not_unique',
              'message': 'Value must be unique.',
            },
          },
        },
      );
      expect(isPocketBaseUniqueViolation(error), isTrue);
    });

    test('false for other 400 errors', () {
      final error = ClientException(
        url: Uri.parse('https://example.com'),
        statusCode: 400,
        response: {
          'data': {
            'amount': {
              'code': 'validation_required',
              'message': 'Cannot be blank.',
            },
          },
        },
      );
      expect(isPocketBaseUniqueViolation(error), isFalse);
    });

    test('false for non-ClientException', () {
      expect(isPocketBaseUniqueViolation(Exception('x')), isFalse);
    });
  });

  group('escapeIdempotencyKeyForFilter', () {
    test('escapes quotes and backslashes', () {
      expect(escapeIdempotencyKeyForFilter(r'a"b\c'), r'a\"b\\c');
    });
  });
}
