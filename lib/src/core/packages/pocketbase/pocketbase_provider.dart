import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../constants/constants.dart';
import '../storage/secure_storage_provider.dart';
import 'pocketbase_http_client.dart';
import 'timeout_http_client.dart';

part 'pocketbase_provider.g.dart';

/// Environment URLs for PocketBase
abstract class PocketBaseUrls {
  static const String dev = 'http://127.0.0.1:8090';
  static const String staging = 'https://staging.ebegym.hznsystems.com';
  static const String prod = 'https://ebegym.hznsystems.com';
}

/// Environment passed via --dart-define=ENV=<value>
/// Valid values: 'dev', 'staging', 'prod'
const String _env = String.fromEnvironment('ENV', defaultValue: '');

/// Optional URL override via --dart-define=API_URL=<url>
/// If set, this takes priority over ENV-based URL resolution.
const String _apiUrlOverride = String.fromEnvironment('API_URL', defaultValue: '');

/// Resolves the PocketBase URL based on environment configuration.
/// Priority: API_URL override > ENV-based URL > kDebugMode fallback.
String get pocketbaseUrl {
  if (_apiUrlOverride.isNotEmpty) return _apiUrlOverride;

  switch (_env) {
    case 'prod':
      return PocketBaseUrls.prod;
    case 'staging':
      return PocketBaseUrls.staging;
    case 'dev':
      return PocketBaseUrls.dev;
    default:
      // Fallback: use kDebugMode for local development
      return kDebugMode ? PocketBaseUrls.dev : PocketBaseUrls.prod;
  }
}

/// Returns the current environment name for display/logging.
String get currentEnvironment {
  if (_env.isNotEmpty) return _env;
  return kDebugMode ? 'dev' : 'prod';
}

/// Returns the app title based on environment.
/// - Dev: "HZN Gyms [Dev]"
/// - Staging: "HZN Gyms [Stg]"
/// - Production: "HZN Gyms"
String get appTitle {
  switch (currentEnvironment) {
    case 'dev':
      return 'HZN Gyms [Dev]';
    case 'staging':
      return 'HZN Gyms [Stg]';
    default:
      return AppConstants.appName;
  }
}

/// Controller for toggling between dev and production PocketBase instances.
///
/// Stores the preference in secure storage and provides methods to toggle.
@Riverpod(keepAlive: true)
class PbDebugController extends _$PbDebugController {
  static const _key = 'pb_debug_mode';

  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);

  @override
  Future<bool> build() async {
    final value = await _storage.read(key: _key);
    return value == 'true';
  }

  /// Toggle between dev and production mode.
  Future<void> toggle() async {
    final current = state.value ?? false;
    await _storage.write(key: _key, value: (!current).toString());
    ref.invalidateSelf();
  }

  /// Get the current debug mode value.
  Future<bool> get() async {
    final value = await _storage.read(key: _key);
    return value == 'true';
  }
}

/// Provides a singleton PocketBase instance.
///
/// The instance uses the URL resolved from --dart-define=ENV or falls back
/// to kDebugMode-based selection.
///
/// Uses [PocketBase.reuseHTTPClient] so the SDK does not call [http.Client.close]
/// after every request. Without that, our shared [TimeoutHttpClient] inner
/// client would be closed on the first API call and all later requests (including
/// `/api/health` polling) would fail — showing "Offline" on the login screen.
///
/// Every request is wrapped with [ApiConstants.requestTimeout] so a dead or
/// very slow connection fails fast with an error instead of leaving the UI
/// spinning indefinitely.
@Riverpod(keepAlive: true)
PocketBase pocketbase(Ref ref) {
  final pb = PocketBase(
    pocketbaseUrl,
    reuseHTTPClient: true,
    httpClientFactory: () => TimeoutHttpClient(
      createPocketBaseHttpClient(),
      ApiConstants.requestTimeout,
    ),
  );
  ref.onDispose(pb.close);
  return pb;
}
