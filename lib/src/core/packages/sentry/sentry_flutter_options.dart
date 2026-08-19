import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../pocketbase/pocketbase_provider.dart';
import 'sentry_config.dart';

/// Configures DSN, environment, and release on [options] from package info.
///
/// PackageInfo is a local `version.json` read on web — it does not wait on
/// Sentry ingest. Callers should still not await [SentryFlutter.init] before
/// first frame.
Future<void> configureSentryFlutterOptions(SentryFlutterOptions options) async {
  final info = await PackageInfo.fromPlatform();

  options.dsn = sentryDsn;
  options.environment = currentEnvironment;
  options.release = sentryReleaseLabel(
    version: info.version,
    buildNumber: info.buildNumber,
  );
  options.dist = info.buildNumber;
  options.tracesSampleRate = 0.2;
}
