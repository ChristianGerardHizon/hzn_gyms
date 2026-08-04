import 'dart:async';

import 'package:http/http.dart' as http;

/// An [http.Client] wrapper that aborts any request taking longer than
/// [timeout], surfacing an error instead of hanging forever.
///
/// Used as the [PocketBase] `httpClientFactory` so every request made
/// through the app (sales, memberships, etc.) fails fast on a slow/dead
/// connection instead of leaving the UI stuck on a loading spinner.
class TimeoutHttpClient extends http.BaseClient {
  TimeoutHttpClient(this._inner, this.timeout);

  final http.Client _inner;
  final Duration timeout;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner.send(request).timeout(
      timeout,
      onTimeout: () {
        // Thrown as http.ClientException (rather than TimeoutException) so
        // PocketBase's client marks it `isAbort: true`, which ErrorDisplayInfo
        // already maps to a dedicated "request timed out" title.
        throw http.ClientException(
          'Request timed out after ${timeout.inSeconds}s',
          request.url,
        );
      },
    );
  }

  @override
  void close() => _inner.close();
}
