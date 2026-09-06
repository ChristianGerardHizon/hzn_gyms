import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/core/utils/color_utils.dart';

void main() {
  group('isAchromaticColor', () {
    test('detects black, white, and gray', () {
      expect(isAchromaticColor(const Color(0xFF000000)), isTrue);
      expect(isAchromaticColor(const Color(0xFFFFFFFF)), isTrue);
      expect(isAchromaticColor(const Color(0xFF808080)), isTrue);
    });

    test('rejects saturated brand colors', () {
      expect(isAchromaticColor(const Color(0xFF1E88E5)), isFalse);
      expect(isAchromaticColor(const Color(0xFFE53935)), isFalse);
    });
  });

  group('colorSchemeFromSeed', () {
    test('black seed uses neutral dark surfaces without red tint', () {
      final scheme = colorSchemeFromSeed(
        seedColor: Colors.black,
        brightness: Brightness.dark,
      );

      expect(scheme.surface, const Color(0xFF131313));
      expect(scheme.primary, const Color(0xFFC6C6C6));
    });

    test('black seed keeps black primary in light mode', () {
      final scheme = colorSchemeFromSeed(
        seedColor: Colors.black,
        brightness: Brightness.light,
      );

      expect(scheme.primary, Colors.black);
      expect(scheme.surface, const Color(0xFFF9F9F9));
    });

    test('chromatic seed still builds a blue palette', () {
      final scheme = colorSchemeFromSeed(
        seedColor: const Color(0xFF1E88E5),
        brightness: Brightness.dark,
      );

      expect(scheme.primary.blue, greaterThan(scheme.primary.red));
    });
  });
}
