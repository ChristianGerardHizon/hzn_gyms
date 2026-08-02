import 'package:ebe_gym/src/application.dart';
import 'package:ebe_gym/src/core/i18n/strings.g.dart';
import 'package:ebe_gym/src/core/packages/pocketbase/pocketbase_provider.dart';
import 'package:ebe_gym/src/core/packages/sentry/sentry_config.dart';
import 'package:ebe_gym/src/core/utils/window_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void runEbeGymApp({Widget? appChild}) {
  WindowUtils.register();
  LocaleSettings.useDeviceLocale();

  final child = appChild ?? const Application();

  runApp(
    ProviderScope(
      child: TranslationProvider(child: child),
    ),
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!isSentryEnabled) {
    runEbeGymApp();
    return;
  }

  await SentryFlutter.init(
    (options) async {
      final info = await PackageInfo.fromPlatform();

      options.dsn = sentryDsn;
      options.environment = currentEnvironment;
      options.release = '${info.version}+${info.buildNumber}';
      options.dist = info.buildNumber;
      options.tracesSampleRate = 0.2;
    },
    appRunner: () => runEbeGymApp(
      appChild: SentryWidget(child: const Application()),
    ),
  );
}
