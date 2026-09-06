/// Compile-time environment from `--dart-define=ENV=<value>`.
const buildEnvironment = String.fromEnvironment('ENV', defaultValue: '');

const prodSentryDsn = String.fromEnvironment(
  'SENTRY_DSN',
  defaultValue:
      'https://637f6ad1e7cdeae93caa163312ff6c93@o418473.ingest.us.sentry.io/4512037316919296',
);

/// Whether Sentry should be initialized for an explicit build [environment].
bool isSentryEnabledForEnvironment(String environment) => environment == 'prod';

/// Whether Sentry is enabled for the current app build.
///
/// Requires an explicit `--dart-define=ENV=prod`; release/profile builds
/// without `ENV` do not enable Sentry.
bool get isSentryEnabled => isSentryEnabledForEnvironment(buildEnvironment);

/// Resolves the Sentry DSN for [environment].
String sentryDsnFor({required String environment, required String prodDsn}) =>
    isSentryEnabledForEnvironment(environment) ? prodDsn : '';

/// Sentry DSN for the current app build, or empty when disabled.
String get sentryDsn => isSentryEnabled ? prodSentryDsn : '';

/// Formats the Sentry `release` value from package version + build number.
String sentryReleaseLabel({
  required String version,
  required String buildNumber,
}) => '$version+$buildNumber';
