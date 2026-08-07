import 'package:flutter/material.dart';

import '../../../settings/domain/branch_color_preset.dart';
import '../../domain/membership.dart';

/// Compact chips showing which branches a membership plan applies to.
///
/// Pill text uses [branchCodeById] (e.g. `BCD`); [branchNameById] is the
/// tooltip (full name like `Bacolod Branch`).
class MembershipValidBranchesChips extends StatelessWidget {
  const MembershipValidBranchesChips({
    super.key,
    required this.membership,
    required this.branchCodeById,
    required this.branchNameById,
    this.branchColorById = const {},
    this.currentBranchId,
    this.maxVisible = 3,
  });

  final Membership membership;
  final Map<String, String> branchCodeById;
  final Map<String, String> branchNameById;
  final Map<String, String> branchColorById;
  final String? currentBranchId;
  final int maxVisible;

  String _pillLabel(String branchId) =>
      branchCodeById[branchId] ??
      branchNameById[branchId] ??
      branchId;

  String _tooltip(String branchId) =>
      branchNameById[branchId] ?? branchCodeById[branchId] ?? branchId;

  Color _colorFor(BuildContext context, String branchId) {
    return BranchColorPreset.resolveColor(
      branchColorById[branchId],
      fallback: Theme.of(context).colorScheme.tertiary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (membership.validBranches.isEmpty) {
      return _BranchChip(
        label: 'All',
        tooltip: 'All branches',
        color: theme.colorScheme.primary,
        icon: Icons.storefront_outlined,
        emphasized: true,
      );
    }

    final sortedIds = List<String>.from(membership.validBranches)
      ..sort((a, b) {
        final aCurrent = a == currentBranchId;
        final bCurrent = b == currentBranchId;
        if (aCurrent != bCurrent) return aCurrent ? -1 : 1;
        return _pillLabel(a).compareTo(_pillLabel(b));
      });

    final visibleIds = sortedIds.take(maxVisible).toList();
    final hiddenIds = sortedIds.skip(maxVisible).toList();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final branchId in visibleIds)
          _BranchChip(
            label: _pillLabel(branchId),
            tooltip: _tooltip(branchId),
            color: _colorFor(context, branchId),
            icon: Icons.storefront_outlined,
            emphasized: branchId == currentBranchId,
          ),
        if (hiddenIds.isNotEmpty)
          _BranchChip(
            label: '+${hiddenIds.length}',
            tooltip: hiddenIds.map(_tooltip).join(', '),
            color: theme.colorScheme.tertiary,
            icon: Icons.more_horiz,
            emphasized: false,
          ),
      ],
    );
  }
}

class _BranchChip extends StatelessWidget {
  const _BranchChip({
    required this.label,
    required this.tooltip,
    required this.color,
    required this.icon,
    required this.emphasized,
  });

  final String label;
  final String tooltip;
  final Color color;
  final IconData icon;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
