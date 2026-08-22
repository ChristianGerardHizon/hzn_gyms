import 'package:kylie_gym/src/core/packages/sentry/sentry_flutter_options.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'configureSentryFlutterOptions sets release and dist from package info',
    () async {
      PackageInfo.setMockInitialValues(
        appName: 'kylie_gym',
        packageName: 'kylie_gym',
        version: '1.22.0',
        buildNumber: '30',
        buildSignature: '',
      );

      final options = SentryFlutterOptions();
      await configureSentryFlutterOptions(options);

      expect(options.release, '1.22.0+30');
      expect(options.dist, '30');
      expect(options.tracesSampleRate, 0.2);
    },
  );
}
