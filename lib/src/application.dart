import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:theme_provider/theme_provider.dart';

import 'core/i18n/strings.g.dart';
import 'core/packages/pocketbase/pocketbase_provider.dart';
import 'core/packages/theme/app_themes.dart';
import 'core/routing/router.dart';
import 'core/widgets/window_size_listener.dart';
import 'features/settings/presentation/controllers/theme_controller.dart';

/// Main application widget.
///
/// Sets up MaterialApp with GoRouter navigation and localization.
class Application extends HookConsumerWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeModeAsync = ref.watch(themeControllerProvider);
    final themeController = ref.read(themeControllerProvider.notifier);

    return ThemeProvider(
      themes: AppThemes.all,
      saveThemesOnChange: false,
      loadThemeOnInit: false,
      child: ThemeConsumer(
        child: Builder(
          builder: (themeContext) {
            // Use system brightness as immediate default (no storage read needed)
            final systemBrightness =
                MediaQuery.platformBrightnessOf(themeContext);
            final systemDefault = systemBrightness == Brightness.dark
                ? AppThemes.darkId
                : AppThemes.lightId;

            // Use persisted preference when available, fall back to system
            final effectiveThemeId = themeModeAsync.whenOrNull(
                  data: (_) =>
                      themeController.getEffectiveThemeId(systemBrightness),
                ) ??
                systemDefault;

            // Apply theme via post-frame callback to avoid build-time mutations
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final controller = ThemeProvider.controllerOf(themeContext);
              if (controller.theme.id != effectiveThemeId) {
                controller.setTheme(effectiveThemeId);
              }
            });

            return WindowSizeListener(
              child: MaterialApp.router(
                scaffoldMessengerKey: rootScaffoldMessengerKey,
                title: appTitle,
                debugShowCheckedModeBanner: false,
                locale: TranslationProvider.of(context).flutterLocale,
                supportedLocales: AppLocaleUtils.supportedLocales,
                localizationsDelegates:
                    GlobalMaterialLocalizations.delegates,
                theme: ThemeProvider.themeOf(themeContext).data,
                routerConfig: router,
              ),
            );
          },
        ),
      ),
    );
  }
}
