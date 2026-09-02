import 'package:flutter/material.dart';

/// Parses a `#RRGGBB` or `#AARRGGBB` hex string into a [Color].
///
/// Returns null for null/empty/malformed input.
Color? colorFromHex(String? hex) {
  final trimmed = hex?.trim() ?? '';
  if (trimmed.isEmpty) return null;

  final stripped = trimmed.startsWith('#') ? trimmed.substring(1) : trimmed;
  if (stripped.length != 6 && stripped.length != 8) return null;

  final withAlpha = stripped.length == 6 ? 'FF$stripped' : stripped;
  final value = int.tryParse(withAlpha, radix: 16);
  if (value == null) return null;

  return Color(value);
}

/// Formats [color] as an uppercase `#RRGGBB` string (alpha ignored).
String colorToHex(Color color) {
  final rgb = color.toARGB32() & 0xFFFFFF;
  return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

/// Normalizes a hex color string to uppercase `#RRGGBB`, or null when invalid.
String? normalizeHexColor(String? hex) {
  final color = colorFromHex(hex);
  if (color == null) return null;
  return colorToHex(color);
}

/// Whether [color] has no meaningful hue (black, white, gray).
bool isAchromaticColor(Color color, {double saturationThreshold = 0.08}) {
  return HSVColor.fromColor(color).saturation <= saturationThreshold;
}

/// Builds a Material 3 [ColorScheme] from an organization seed color.
///
/// Achromatic seeds (e.g. `#000000`) use [DynamicSchemeVariant.fidelity] so
/// surfaces and accents stay neutral instead of picking an arbitrary hue.
ColorScheme colorSchemeFromSeed({
  required Color seedColor,
  required Brightness brightness,
}) {
  return ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
    dynamicSchemeVariant: isAchromaticColor(seedColor)
        ? DynamicSchemeVariant.fidelity
        : DynamicSchemeVariant.tonalSpot,
  );
}
