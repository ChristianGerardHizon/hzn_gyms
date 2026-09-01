import 'package:hzn_gyms/src/application.dart';
import 'package:hzn_gyms/src/core/i18n/strings.g.dart';
import 'package:hzn_gyms/src/core/packages/sentry/sentry_config.dart';
import 'package:hzn_gyms/src/core/packages/sentry/sentry_flutter_options.dart';
import 'package:hzn_gyms/src/core/packages/sentry/sentry_startup_error_buffer.dart';
import 'package:hzn_gyms/src/core/utils/window_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void runHznGymsApp({Widget? appChild}) {
  WindowUtils.register();
  LocaleSettings.useDeviceLocale();

  final child = appChild ?? const Application();

  runApp(ProviderScope(child: TranslationProvider(child: child)));
}

Future<void> main() async {
  if (!isSentryEnabled) {
    WidgetsFlutterBinding.ensureInitialized();
    runHznGymsApp();
    return;
  }

  // On web, SentryFlutter.init wraps appRunner in runZonedGuarded when started
  // from the root zone. Calling ensureInitialized (or PackageInfo) in the root
  // zone then runApp inside that child zone causes "Zone mismatch" (EBEGYM-3).
  // Enter Sentry's zone first so bindings and runApp share the same zone.
  // runApp before awaiting init so first paint is not blocked on Sentry ingest.
  // Queue zone errors until init binds the DSN, then flush them.
  final startupErrors = SentryStartupErrorBuffer();
  await Sentry.runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      runHznGymsApp(appChild: SentryWidget(child: const Application()));

      await SentryFlutter.init(configureSentryFlutterOptions);
      await startupErrors.markReadyAndFlush();
    },
    (error, stackTrace) {
      startupErrors.add(error, stackTrace);
    },
  );
}
