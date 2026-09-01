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
