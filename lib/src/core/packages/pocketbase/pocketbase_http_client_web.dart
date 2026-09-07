import 'package:fetch_client/fetch_client.dart';
import 'package:http/http.dart' as http;

/// Web client with streaming support required for PocketBase realtime OAuth2.
http.Client createPocketBaseHttpClient() =>
    FetchClient(mode: RequestMode.cors);
