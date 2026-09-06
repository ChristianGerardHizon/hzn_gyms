import 'package:http/http.dart' as http;
import 'package:hzn_gyms/src/core/packages/pocketbase/timeout_http_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'PocketBase per-request close breaks a shared TimeoutHttpClient inner client',
    () async {
      final inner = http.Client();
      addTearDown(inner.close);

      http.Client wrap() =>
          TimeoutHttpClient(inner, const Duration(seconds: 30));

      // PocketBase send() closes the factory client after each request when
      // reuseHTTPClient is false.
      wrap().close();

      await expectLater(
        wrap().get(Uri.parse('http://127.0.0.1:8090/api/health')),
        throwsA(
          predicate<Object>(
            (e) =>
                e is http.ClientException &&
                e.message.contains('Client is already closed'),
          ),
        ),
      );
    },
  );
}
