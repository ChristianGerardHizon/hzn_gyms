import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/core/utils/currency_format.dart';
import 'package:hzn_gyms/src/core/utils/file_validation.dart';

void main() {
  group('formatCurrency', () {
    test('formats with peso symbol and commas', () {
      expect(formatCurrency(1234.56), '₱1,234.56');
      expect(100.toCurrency(), '₱100.00');
    });
  });

  group('FileValidation', () {
    test('validateFileSize rejects oversized files', () {
      expect(FileValidation.validateFileSize(1024), isNull);
      expect(
        FileValidation.validateFileSize(FileValidation.maxFileSizeBytes + 1),
        contains('exceeds'),
      );
    });

    test('validateFileExtension is case-insensitive', () {
      expect(FileValidation.validateFileExtension('photo.JPG'), isNull);
      expect(FileValidation.validateFileExtension('doc.exe'), contains('not supported'));
    });

    test('validate returns first failing check', () {
      expect(FileValidation.validate('a.pdf', 100), isNull);
      expect(FileValidation.validate('a.exe', 100), contains('not supported'));
    });

    test('type helpers', () {
      expect(FileValidation.isImage('a.png'), isTrue);
      expect(FileValidation.isVideo('a.mp4'), isTrue);
      expect(FileValidation.isDocument('a.pdf'), isTrue);
      expect(FileValidation.isImage('a.pdf'), isFalse);
    });

    test('formatFileSize', () {
      expect(FileValidation.formatFileSize(500), '500 B');
      expect(FileValidation.formatFileSize(2048), '2.0 KB');
      expect(FileValidation.formatFileSize(2 * 1024 * 1024), '2.0 MB');
    });

    test('no extension is invalid', () {
      expect(FileValidation.isFileExtensionValid('noext'), isFalse);
    });
  });
}
