import 'package:http/http.dart' as http;

import 'pocketbase_http_client_stub.dart'
    if (dart.library.html) 'pocketbase_http_client_web.dart' as impl;

/// Platform HTTP client for PocketBase.
///
/// Web uses [FetchClient] so realtime/SSE (needed by `authWithOAuth2`) works.
http.Client createPocketBaseHttpClient() => impl.createPocketBaseHttpClient();
