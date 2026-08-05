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
  if (!isSentryEnabled) {
    WidgetsFlutterBinding.ensureInitialized();
    runEbeGymApp();
    return;
  }

  // On web, SentryFlutter.init wraps appRunner in runZonedGuarded when started
  // from the root zone. Calling ensureInitialized (or PackageInfo) in the root
  // zone then runApp inside that child zone causes "Zone mismatch" (EBEGYM-3).
  // Enter Sentry's zone first so bindings and runApp share the same zone; init
  // then skips creating a nested zone because we are no longer in the root zone.
  await Sentry.runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await SentryFlutter.init(
      (options) async {
        final info = await PackageInfo.fromPlatform();

        options.dsn = sentryDsn;
        options.environment = currentEnvironment;
        options.release = sentryReleaseLabel(
          version: info.version,
          buildNumber: info.buildNumber,
        );
        options.dist = info.buildNumber;
        options.tracesSampleRate = 0.2;
      },
      appRunner: () => runEbeGymApp(
        appChild: SentryWidget(child: const Application()),
      ),
    );
  }, (error, stackTrace) {
    // Sentry.runZonedGuarded already reports [error].
  });
}
