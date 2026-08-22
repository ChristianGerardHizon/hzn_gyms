import 'package:kylie_gym/src/features/settings/domain/branch_color_preset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BranchColorPreset', () {
    test('exposes eight presets', () {
      expect(BranchColorPreset.presets, hasLength(8));
      expect(
        BranchColorPreset.presets.map((p) => p.id).toSet(),
        {
          'teal',
          'blue',
          'indigo',
          'purple',
          'pink',
          'orange',
          'green',
          'cyan',
        },
      );
    });

    test('byId resolves known ids case-insensitively', () {
      expect(BranchColorPreset.byId('teal'), BranchColorPreset.teal);
      expect(BranchColorPreset.byId('INDIGO'), BranchColorPreset.indigo);
    });

    test('byId returns null for empty or unknown', () {
      expect(BranchColorPreset.byId(null), isNull);
      expect(BranchColorPreset.byId(''), isNull);
      expect(BranchColorPreset.byId('   '), isNull);
      expect(BranchColorPreset.byId('magenta'), isNull);
    });

    test('resolveColor uses preset or fallback', () {
      const fallback = Color(0xFF112233);
      expect(
        BranchColorPreset.resolveColor('teal', fallback: fallback),
        BranchColorPreset.teal.color,
      );
      expect(
        BranchColorPreset.resolveColor(null, fallback: fallback),
        fallback,
      );
      expect(
        BranchColorPreset.resolveColor('nope', fallback: fallback),
        fallback,
      );
    });
  });
}
