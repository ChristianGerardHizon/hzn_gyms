import 'package:flutter/material.dart';

import '../../../memberships/domain/member_branch_activity.dart';

/// Noticeable branch-activity chips for a member in list views.
class MemberBranchActivityChips extends StatelessWidget {
  const MemberBranchActivityChips({
    super.key,
    required this.activity,
    required this.branchNameById,
    this.currentBranchId,
    this.isLoading = false,
  });

  final MemberBranchActivity? activity;
  final Map<String, String> branchNameById;
  final String? currentBranchId;
  final bool isLoading;

  static const _maxVisibleChips = 3;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        height: 22,
        width: 72,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Color(0x14000000),
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      );
    }

    final resolved = activity ?? const MemberBranchActivity(branchIds: {});
    final allBranchIds = branchNameById.keys.toList();

    if (resolved.isEmpty) {
      return _ActivityChip(
        label: 'No active branch',
        color: Colors.orange.shade800,
        icon: Icons.location_off_outlined,
        emphasized: true,
      );
    }

    if (resolved.coversAllBranches(allBranchIds)) {
      return _ActivityChip(
        label: 'All branches',
        color: Colors.green.shade700,
        icon: Icons.storefront_outlined,
        emphasized: true,
      );
    }

    final sortedBranchIds = resolved.branchIds.toList()
      ..sort((a, b) {
        final aCurrent = a == currentBranchId;
        final bCurrent = b == currentBranchId;
        if (aCurrent != bCurrent) return aCurrent ? -1 : 1;
        final aName = branchNameById[a] ?? a;
        final bName = branchNameById[b] ?? b;
        return aName.compareTo(bName);
      });

    final visibleIds = sortedBranchIds.take(_maxVisibleChips).toList();
    final hiddenIds = sortedBranchIds.skip(_maxVisibleChips).toList();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final branchId in visibleIds)
          _ActivityChip(
            label: branchNameById[branchId] ?? branchId,
            color: Colors.green.shade700,
            icon: Icons.storefront_outlined,
            emphasized: branchId == currentBranchId,
          ),
        if (hiddenIds.isNotEmpty)
          Tooltip(
            message: hiddenIds
                .map((id) => branchNameById[id] ?? id)
                .join(', '),
            child: _ActivityChip(
              label: '+${hiddenIds.length} more',
              color: Colors.green.shade700,
              icon: Icons.more_horiz,
              emphasized: false,
            ),
          ),
      ],
    );
  }
}

class _ActivityChip extends StatelessWidget {
  const _ActivityChip({
    required this.label,
    required this.color,
    required this.icon,
    required this.emphasized,
  });

  final String label;
  final Color color;
  final IconData icon;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}
