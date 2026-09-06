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
  });
}
