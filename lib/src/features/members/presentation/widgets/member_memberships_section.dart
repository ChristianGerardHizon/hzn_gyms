import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/branch_code_pill.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../../memberships/domain/days_remaining_label.dart';
import '../../../memberships/domain/member_membership.dart';
import '../../../memberships/domain/membership_status_colors.dart';
import '../../../memberships/presentation/controllers/member_memberships_controller.dart';
import '../../../memberships/presentation/widgets/member_membership_detail_dialog.dart';
import '../../../settings/presentation/controllers/branches_controller.dart';

/// Displays a member's memberships on the member detail page.
///
/// Active (and upcoming) memberships are shown by default; inactive ones
/// are collapsed behind a "Show other memberships" control.
class MemberMembershipsSection extends HookConsumerWidget {
  const MemberMembershipsSection({
    super.key,
    required this.memberId,
    required this.memberName,
  });

  final String memberId;
  final String memberName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipsAsync = ref.watch(
      memberMembershipsControllerProvider(memberId),
    );
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final showOther = useState(false);

    return membershipsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (error, _) => ErrorState.fromError(error, compact: true),
      data: (memberships) {
        if (memberships.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.card_membership_outlined,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No memberships yet',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final primary = memberships
            .where((m) => m.isPrimaryActiveList)
            .toList();
        final other = memberships
            .where((m) => !m.isPrimaryActiveList)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (primary.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No active memberships',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
            else
              _MembershipsList(
                memberships: primary,
                memberId: memberId,
                memberName: memberName,
                dateFormat: dateFormat,
              ),
            if (other.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: () => showOther.value = !showOther.value,
                  icon: Icon(
                    showOther.value ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                  ),
                  label: Text(
                    showOther.value
                        ? 'Hide other memberships'
                        : 'Show other memberships (${other.length})',
                  ),
                ),
              ),
              if (showOther.value)
                _MembershipsList(
                  memberships: other,
                  memberId: memberId,
                  memberName: memberName,
                  dateFormat: dateFormat,
                ),
            ],
          ],
        );
      },
    );
  }
}

class _MembershipsList extends ConsumerWidget {
  const _MembershipsList({
    required this.memberships,
    required this.memberId,
    required this.memberName,
    required this.dateFormat,
  });

  final List<MemberMembership> memberships;
  final String memberId;
  final String memberName;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final branches = ref.watch(branchesControllerProvider).value ?? const [];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: memberships.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final mm = memberships[index];
        final effectiveExpired =
            mm.isExpired && mm.status == MemberMembershipStatus.active;
        final statusColor = membershipStatusColor(
          mm.status,
          effectiveExpired: effectiveExpired,
        );
        final branchPill = BranchCodePill.fromBranches(
          branchId: mm.branchId,
          branches: branches,
          dense: true,
        );

        return ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: () => showMemberMembershipDetailDialog(
            context,
            memberMembership: mm,
            memberId: memberId,
            memberName: memberName,
          ),
          leading: CircleAvatar(
            backgroundColor: statusColor.withValues(alpha: 0.15),
            child: Icon(
              Icons.card_membership,
              color: statusColor,
              size: 20,
            ),
          ),
          title: Text(mm.membershipName ?? 'Membership'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${dateFormat.format(mm.startDate)} - ${dateFormat.format(mm.endDate)}',
                style: theme.textTheme.bodySmall,
              ),
              if (branchPill != null) ...[
                const SizedBox(height: 4),
                branchPill,
              ],
            ],
          ),
          isThreeLine: branchPill != null,
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  effectiveExpired ? 'Expired' : mm.status.displayName,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (mm.isCurrentlyActive) ...[
                const SizedBox(height: 4),
                Text(
                  formatDaysRemainingLabel(mm.daysRemaining),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: membershipLifecycleColor(
                      daysRemaining: mm.daysRemaining,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
