import '../pocketbase/pocketbase_provider.dart';

const prodSentryDsn = String.fromEnvironment(
  'SENTRY_DSN',
  defaultValue:
      'https://1945b89861c8a0b663765b846303976f@o418473.ingest.us.sentry.io/4511839793577984',
);

/// Whether Sentry should be initialized for [environment].
bool isSentryEnabledForEnvironment(String environment) => environment == 'prod';

/// Resolves the Sentry DSN for [environment].
String sentryDsnFor({
  required String environment,
  required String prodDsn,
}) =>
    isSentryEnabledForEnvironment(environment) ? prodDsn : '';

/// Whether Sentry is enabled for the current app build.
bool get isSentryEnabled => isSentryEnabledForEnvironment(currentEnvironment);

/// Sentry DSN for the current app build, or empty when disabled.
String get sentryDsn =>
    sentryDsnFor(environment: currentEnvironment, prodDsn: prodSentryDsn);
