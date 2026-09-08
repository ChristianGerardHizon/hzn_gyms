import 'package:flutter/material.dart';

import '../../utils/color_utils.dart';

/// App theme definitions for light and dark modes.
///
/// Uses Material 3 with a seed-based color scheme. The seed color is a
/// parameter (not a constant) so it can reflect the current organization's
/// branding — see `effectiveSeedColorProvider`.
class AppThemes {
  AppThemes._();

  /// Fallback seed color used before an organization's branding resolves,
  /// or for organizations that haven't set one.
  static const Color defaultSeedColor = Colors.blue;

  /// Light theme definition for [seedColor].
  static ThemeData light(Color seedColor) => ThemeData(
        colorScheme: colorSchemeFromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      );

  /// Dark theme definition for [seedColor].
  ///
  /// FAB uses [ColorScheme.primary] instead of the M3 default
  /// `primaryContainer`, which is too close to dark surfaces (especially with
  /// achromatic org seeds) and makes the button hard to see.
  static ThemeData dark(Color seedColor) {
    final colorScheme = colorSchemeFromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );
    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}
