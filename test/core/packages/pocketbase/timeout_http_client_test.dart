import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ebe_gym/src/core/packages/pocketbase/timeout_http_client.dart';

void main() {
  group('TimeoutHttpClient', () {
    test('passes through a response that completes in time', () async {
      final mock = MockClient((request) async {
        return http.Response('ok', 200);
      });
      final client = TimeoutHttpClient(mock, const Duration(seconds: 1));

      final response =
          await client.get(Uri.parse('https://example.com/fast'));

      expect(response.statusCode, 200);
      expect(response.body, 'ok');
    });

    test('throws http.ClientException when the request exceeds the timeout',
        () async {
      final mock = MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
        return http.Response('too late', 200);
      });
      final client =
          TimeoutHttpClient(mock, const Duration(milliseconds: 10));

      await expectLater(
        client.get(Uri.parse('https://example.com/slow')),
        throwsA(isA<http.ClientException>()),
      );
    });
  });
}
