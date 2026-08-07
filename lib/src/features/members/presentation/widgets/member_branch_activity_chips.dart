import 'package:flutter/material.dart';

import '../../../memberships/domain/member_branch_activity.dart';
import '../../../settings/domain/branch_color_preset.dart';

/// Noticeable branch-activity chips for a member in list views.
///
/// Pill text uses [branchCodeById] (e.g. `BCD`); [branchNameById] is the
/// tooltip (full name).
class MemberBranchActivityChips extends StatelessWidget {
  const MemberBranchActivityChips({
    super.key,
    required this.activity,
    required this.branchCodeById,
    required this.branchNameById,
    this.branchColorById = const {},
    this.currentBranchId,
    this.isLoading = false,
    this.dense = false,
  });

  final MemberBranchActivity? activity;
  final Map<String, String> branchCodeById;
  final Map<String, String> branchNameById;
  final Map<String, String> branchColorById;
  final String? currentBranchId;
  final bool isLoading;

  /// Tighter padding for trailing placement in list rows.
  final bool dense;

  static const _maxVisibleChips = 3;

  String _pillLabel(String branchId) =>
      branchCodeById[branchId] ?? branchNameById[branchId] ?? branchId;

  String _tooltip(String branchId) =>
      branchNameById[branchId] ?? branchCodeById[branchId] ?? branchId;

  Color _colorFor(BuildContext context, String branchId) {
    return BranchColorPreset.resolveColor(
      branchColorById[branchId],
      fallback: Colors.green.shade700,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: dense ? 18 : 22,
        width: dense ? 56 : 72,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0x14000000),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
    }

    final resolved = activity ?? const MemberBranchActivity(branchIds: {});
    final allBranchIds = {
      ...branchCodeById.keys,
      ...branchNameById.keys,
    }.toList();

    if (resolved.isEmpty) {
      final muted = Theme.of(context).colorScheme.onSurfaceVariant;
      return _ActivityChip(
        label: 'None',
        tooltip: 'No active branch',
        color: muted,
        icon: Icons.location_off_outlined,
        emphasized: false,
        dense: dense,
      );
    }

    if (resolved.coversAllBranches(allBranchIds)) {
      return _ActivityChip(
        label: 'All',
        tooltip: 'All branches',
        color: const Color(0xFF2E7D32),
        icon: Icons.storefront_outlined,
        emphasized: true,
        dense: dense,
      );
    }

    final sortedBranchIds = resolved.branchIds.toList()
      ..sort((a, b) {
        final aCurrent = a == currentBranchId;
        final bCurrent = b == currentBranchId;
        if (aCurrent != bCurrent) return aCurrent ? -1 : 1;
        return _pillLabel(a).compareTo(_pillLabel(b));
      });

    final visibleIds = sortedBranchIds.take(_maxVisibleChips).toList();
    final hiddenIds = sortedBranchIds.skip(_maxVisibleChips).toList();

    return Wrap(
      spacing: dense ? 4 : 6,
      runSpacing: dense ? 2 : 4,
      alignment: WrapAlignment.end,
      children: [
        for (final branchId in visibleIds)
          _ActivityChip(
            label: _pillLabel(branchId),
            tooltip: _tooltip(branchId),
            color: _colorFor(context, branchId),
            icon: Icons.storefront_outlined,
            emphasized: branchId == currentBranchId,
            dense: dense,
          ),
        if (hiddenIds.isNotEmpty)
          _ActivityChip(
            label: '+${hiddenIds.length}',
            tooltip: hiddenIds.map(_tooltip).join(', '),
            color: Colors.green.shade700,
            icon: Icons.more_horiz,
            emphasized: false,
            dense: dense,
          ),
      ],
    );
  }
}

class _ActivityChip extends StatelessWidget {
  const _ActivityChip({
    required this.label,
    required this.tooltip,
    required this.color,
    required this.icon,
    required this.emphasized,
    this.dense = false,
  });

  final String label;
  final String tooltip;
  final Color color;
  final IconData icon;
  final bool emphasized;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final horizontal = dense ? 6.0 : 8.0;
    final vertical = dense ? 2.0 : 3.0;
    final iconSize = dense ? 11.0 : 13.0;
    final fontSize = dense ? 10.0 : 11.0;

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: horizontal,
          vertical: vertical,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: emphasized ? 0.18 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: emphasized ? 0.65 : 0.35),
            width: emphasized ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: iconSize),
            SizedBox(width: dense ? 3 : 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: fontSize,
                fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
