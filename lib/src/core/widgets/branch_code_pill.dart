import 'package:flutter/material.dart';

import '../../features/settings/domain/branch.dart';
import '../../features/settings/domain/branch_color_preset.dart';

/// Compact branch-code pill (e.g. `BCD`) with full name as tooltip.
class BranchCodePill extends StatelessWidget {
  const BranchCodePill({
    super.key,
    required this.label,
    this.tooltip,
    this.color,
    this.dense = false,
  });

  /// Short code shown on the pill.
  final String label;

  /// Full branch name (or other detail) for the tooltip.
  final String? tooltip;

  /// Accent color; defaults to theme tertiary.
  final Color? color;

  /// Tighter padding for cards / trailing rows.
  final bool dense;

  /// Resolves a [BranchCodePill] from a branch id and branch list.
  ///
  /// Returns null when [branchId] is empty.
  /// Uses the branch's color preset when [color] override is omitted.
  static BranchCodePill? fromBranches({
    required String? branchId,
    required List<Branch> branches,
    Color? color,
    bool dense = false,
  }) {
    if (branchId == null || branchId.isEmpty) return null;

    Branch? match;
    for (final branch in branches) {
      if (branch.id == branchId) {
        match = branch;
        break;
      }
    }

    final resolvedColor = color ??
        (match != null
            ? BranchColorPreset.byId(match.color)?.color
            : null);

    return BranchCodePill(
      label: match?.pillLabel ?? branchId,
      tooltip: match?.name ?? branchId,
      color: resolvedColor,
      dense: dense,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = color ?? theme.colorScheme.tertiary;
    final horizontal = dense ? 6.0 : 8.0;
    final vertical = dense ? 2.0 : 3.0;

    final pill = Container(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.storefront_outlined, color: accent, size: dense ? 11 : 13),
          SizedBox(width: dense ? 3 : 4),
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: dense ? 10 : 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );

    final message = tooltip?.trim();
    if (message == null || message.isEmpty) return pill;
    return Tooltip(message: message, child: pill);
  }
}

/// Builds label and color maps from [branches].
({
  Map<String, String> codeById,
  Map<String, String> nameById,
  Map<String, String> colorById,
}) branchLabelMaps(List<Branch> branches) {
  return (
    codeById: {for (final b in branches) b.id: b.pillLabel},
    nameById: {for (final b in branches) b.id: b.name},
    colorById: {
      for (final b in branches)
        if (b.color != null && b.color!.trim().isNotEmpty) b.id: b.color!,
    },
  );
}
