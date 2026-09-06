import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/i18n/strings.g.dart';
import 'core/packages/theme/app_themes.dart';
import 'core/routing/router.dart';
import 'core/widgets/org_loading_splash.dart';
import 'core/widgets/window_size_listener.dart';
import 'features/organizations/presentation/controllers/current_organization_controller.dart';
import 'features/organizations/presentation/controllers/organization_branding_providers.dart';
import 'features/settings/presentation/controllers/theme_controller.dart';

/// Main application widget.
///
/// Sets up MaterialApp with GoRouter navigation and localization. Gates on
/// current-organization resolution for signed-in users so branding (seed color,
/// title) is correct before the main shell renders.
class Application extends HookConsumerWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orgResolution = ref.watch(currentOrganizationControllerProvider);

    // Only gate on the *initial* resolution — once we have any value (data
    // or null-after-error), keep rendering the app while orgs are re-fetched
    // in the background (e.g. after switching), rather than flashing back to
    // the loading screen.
    if (orgResolution.isLoading && !orgResolution.hasValue) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: OrgLoadingSplash(),
      );
    }

    final router = ref.watch(routerProvider);
    final seedColor = ref.watch(effectiveSeedColorProvider);
    final title = ref.watch(effectiveAppTitleProvider);
    final themeMode = ref.watch(currentThemeModeProvider).toThemeMode;

    return WindowSizeListener(
      child: MaterialApp.router(
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        title: title,
        debugShowCheckedModeBanner: false,
        locale: TranslationProvider.of(context).flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        theme: AppThemes.light(seedColor),
        darkTheme: AppThemes.dark(seedColor),
        themeMode: themeMode,
        routerConfig: router,
      ),
    );
  }
}
