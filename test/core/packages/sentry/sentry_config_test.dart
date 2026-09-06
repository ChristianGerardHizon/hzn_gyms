import 'package:hzn_gyms/src/core/packages/sentry/sentry_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isSentryEnabledForEnvironment', () {
    test('is enabled only for prod', () {
      expect(isSentryEnabledForEnvironment('prod'), isTrue);
      expect(isSentryEnabledForEnvironment('staging'), isFalse);
      expect(isSentryEnabledForEnvironment('dev'), isFalse);
      expect(isSentryEnabledForEnvironment(''), isFalse);
    });
  });

  group('sentryDsnFor', () {
    const dsn = 'https://example.ingest.sentry.io/123';

    test('returns prod DSN only for prod environment', () {
      expect(sentryDsnFor(environment: 'prod', prodDsn: dsn), dsn);
      expect(sentryDsnFor(environment: 'staging', prodDsn: dsn), isEmpty);
      expect(sentryDsnFor(environment: 'dev', prodDsn: dsn), isEmpty);
    });
  });

  group('prodSentryDsn', () {
    test('defaults to the hzn-gyms ingest project', () {
      expect(prodSentryDsn, contains('o418473.ingest.us.sentry.io'));
      expect(prodSentryDsn, contains('4512037316919296'));
    });
  });

  group('sentryReleaseLabel', () {
    test('joins version and build number with plus', () {
      expect(
        sentryReleaseLabel(version: '1.22.0', buildNumber: '30'),
        '1.22.0+30',
      );
    });
  });
}
