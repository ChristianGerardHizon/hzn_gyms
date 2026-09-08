import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/core/packages/theme/app_themes.dart';

void main() {
  group('AppThemes', () {
    test('dark theme with black seed uses neutral surfaces', () {
      final theme = AppThemes.dark(Colors.black);

      expect(theme.colorScheme.surface, const Color(0xFF131313));
      expect(theme.colorScheme.primary, const Color(0xFFC6C6C6));
    });

    test('dark FAB uses primary so it stays visible on dark surfaces', () {
      final theme = AppThemes.dark(Colors.black);
      final fab = theme.floatingActionButtonTheme;

      expect(fab.backgroundColor, theme.colorScheme.primary);
      expect(fab.foregroundColor, theme.colorScheme.onPrimary);
      expect(
        fab.backgroundColor,
        isNot(theme.colorScheme.surface),
      );
    });
  });
}
