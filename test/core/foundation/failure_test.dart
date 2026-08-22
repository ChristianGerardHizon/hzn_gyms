import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:kylie_gym/src/core/foundation/error_display.dart';
import 'package:kylie_gym/src/core/foundation/failure.dart';
import 'package:kylie_gym/src/core/i18n/strings.g.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Failure.messageString', () {
    test('returns string message directly', () {
      expect(const GenericFailure('boom').messageString, 'boom');
    });

    test('unwraps nested Failure', () {
      const inner = GenericFailure('inner');
      expect(const DataFailure(inner).messageString, 'inner');
    });

    test('uses ClientException response message', () {
      final error = ClientException(
        url: Uri.parse('https://example.com'),
        statusCode: 400,
        response: {'message': 'Bad input'},
      );
      expect(PocketbaseFailure(error).messageString, 'Bad input');
    });

    test('falls back to HTTP status text', () {
      final error = ClientException(
        url: Uri.parse('https://example.com'),
        statusCode: 500,
        response: const {},
      );
      expect(
        PocketbaseFailure(error).messageString,
        'Server request failed (HTTP 500)',
      );
    });

    test('returns a friendly message for aborted/timed-out requests', () {
      final error = ClientException(
        url: Uri.parse('https://example.com'),
        isAbort: true,
        originalError: http.ClientException('Request timed out after 30s'),
      );
      expect(
        PocketbaseFailure(error).messageString,
        'Request timed out. Please check your connection and try again.',
      );
    });
  });

  group('Failure.handle', () {
    test('returns existing Failure unchanged', () {
      const failure = AuthFailure('nope');
      expect(
        identical(Failure.handle(failure, StackTrace.empty), failure),
        isTrue,
      );
    });

    test('maps 401 ClientException to AuthFailure', () {
      final error = ClientException(
        url: Uri.parse('https://example.com'),
        statusCode: 401,
        response: const {},
      );
      expect(Failure.handle(error, StackTrace.empty), isA<AuthFailure>());
    });

    test('maps FormatException to PresentationFailure', () {
      expect(
        Failure.handle(const FormatException('bad'), StackTrace.empty),
        isA<PresentationFailure>(),
      );
    });

    test('maps unknown to GenericFailure', () {
      expect(
        Failure.handle(Exception('x'), StackTrace.empty),
        isA<GenericFailure>(),
      );
    });

    test('maps user cancelled text to CancelledFailure', () {
      expect(
        Failure.handle(Exception('User cancelled'), StackTrace.empty),
        isA<CancelledFailure>(),
      );
    });
  });

  group('ErrorDisplayInfo', () {
    late Translations translations;

    setUp(() {
      translations = AppLocale.en.buildSync();
    });

    test('maps HTTP status titles', () {
      final info = ErrorDisplayInfo.from(
        ClientException(
          url: Uri.parse('https://example.com'),
          statusCode: 404,
          response: {'message': 'Missing'},
        ),
        translations: translations,
      );
      expect(info.title, translations.failures.notFound);
      expect(info.message, 'Missing');
      expect(info.statusCode, 404);
      expect(info.copyText, contains('Missing'));
      expect(info.copyText, contains('HTTP 404'));
    });

    test('uses generic title for Failure without client', () {
      final info = ErrorDisplayInfo.from(
        const GenericFailure('oops'),
        translations: translations,
      );
      expect(info.title, translations.failures.generic);
      expect(info.message, 'oops');
    });

    test('detects network-looking raw errors', () {
      final info = ErrorDisplayInfo.from(
        Exception('SocketException: connection failed'),
        translations: translations,
      );
      expect(info.title, translations.failures.networkError);
    });
  });
}
