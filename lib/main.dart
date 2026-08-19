import 'dart:async';

import 'package:ebe_gym/src/application.dart';
import 'package:ebe_gym/src/core/i18n/strings.g.dart';
import 'package:ebe_gym/src/core/packages/sentry/sentry_config.dart';
import 'package:ebe_gym/src/core/packages/sentry/sentry_flutter_options.dart';
import 'package:ebe_gym/src/core/utils/window_utils.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void runEbeGymApp({Widget? appChild}) {
  WindowUtils.register();
  LocaleSettings.useDeviceLocale();

  final child = appChild ?? const Application();

  runApp(ProviderScope(child: TranslationProvider(child: child)));
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
  // Enter Sentry's zone first so bindings and runApp share the same zone.
  // Do not await SentryFlutter.init before runApp: first paint must not wait
  // on Sentry ingest. Init without appRunner so it does not create a nested zone.
  await Sentry.runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      runEbeGymApp(appChild: SentryWidget(child: const Application()));

      unawaited(SentryFlutter.init(configureSentryFlutterOptions));
    },
    (error, stackTrace) {
      // Sentry.runZonedGuarded already reports [error].
    },
  );
}
