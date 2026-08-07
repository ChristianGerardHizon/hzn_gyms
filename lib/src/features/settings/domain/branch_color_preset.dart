import 'package:flutter/material.dart';

/// Fixed accent presets selectable for branch pills.
class BranchColorPreset {
  const BranchColorPreset({
    required this.id,
    required this.label,
    required this.color,
  });

  final String id;
  final String label;
  final Color color;

  static const teal = BranchColorPreset(
    id: 'teal',
    label: 'Teal',
    color: Color(0xFF00897B),
  );
  static const blue = BranchColorPreset(
    id: 'blue',
    label: 'Blue',
    color: Color(0xFF1E88E5),
  );
  static const indigo = BranchColorPreset(
    id: 'indigo',
    label: 'Indigo',
    color: Color(0xFF3949AB),
  );
  static const purple = BranchColorPreset(
    id: 'purple',
    label: 'Purple',
    color: Color(0xFF8E24AA),
  );
  static const pink = BranchColorPreset(
    id: 'pink',
    label: 'Pink',
    color: Color(0xFFD81B60),
  );
  static const orange = BranchColorPreset(
    id: 'orange',
    label: 'Orange',
    color: Color(0xFFFB8C00),
  );
  static const green = BranchColorPreset(
    id: 'green',
    label: 'Green',
    color: Color(0xFF43A047),
  );
  static const cyan = BranchColorPreset(
    id: 'cyan',
    label: 'Cyan',
    color: Color(0xFF00ACC1),
  );

  static const List<BranchColorPreset> presets = [
    teal,
    blue,
    indigo,
    purple,
    pink,
    orange,
    green,
    cyan,
  ];

  /// Returns the preset for [id], or null if empty/unknown.
  static BranchColorPreset? byId(String? id) {
    final key = id?.trim().toLowerCase();
    if (key == null || key.isEmpty) return null;
    for (final preset in presets) {
      if (preset.id == key) return preset;
    }
    return null;
  }

  /// Resolves a stored preset id to a [Color], or [fallback] when unset/unknown.
  static Color resolveColor(String? id, {required Color fallback}) {
    return byId(id)?.color ?? fallback;
  }
}
