/// Compile-time environment from `--dart-define=ENV=<value>`.
const buildEnvironment = String.fromEnvironment('ENV', defaultValue: '');

const prodSentryDsn = String.fromEnvironment(
  'SENTRY_DSN',
  defaultValue:
      'https://1945b89861c8a0b663765b846303976f@o418473.ingest.us.sentry.io/4511839793577984',
);

/// Whether Sentry should be initialized for an explicit build [environment].
bool isSentryEnabledForEnvironment(String environment) => environment == 'prod';

/// Whether Sentry is enabled for the current app build.
///
/// Requires an explicit `--dart-define=ENV=prod`; release/profile builds
/// without `ENV` do not enable Sentry.
bool get isSentryEnabled => isSentryEnabledForEnvironment(buildEnvironment);

/// Resolves the Sentry DSN for [environment].
String sentryDsnFor({
  required String environment,
  required String prodDsn,
}) =>
    isSentryEnabledForEnvironment(environment) ? prodDsn : '';

/// Sentry DSN for the current app build, or empty when disabled.
String get sentryDsn => isSentryEnabled ? prodSentryDsn : '';
