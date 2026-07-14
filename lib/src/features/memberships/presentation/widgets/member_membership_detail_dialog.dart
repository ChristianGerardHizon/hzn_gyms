import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../domain/member_membership.dart';
import '../controllers/member_membership_add_ons_provider.dart';
import '../controllers/membership_provider.dart';
import 'purchase_membership_dialog.dart';

/// Shows details for a member's membership subscription.
Future<void> showMemberMembershipDetailDialog(
  BuildContext context, {
  required MemberMembership memberMembership,
  required String memberId,
  required String memberName,
}) {
  return showConstrainedDialog<void>(
    context: context,
    maxWidth: DialogConstraints.compactMaxWidth,
    barrierDismissible: true,
    builder: (context) => MemberMembershipDetailDialog(
      memberMembership: memberMembership,
      memberId: memberId,
      memberName: memberName,
    ),
  );
}

class MemberMembershipDetailDialog extends ConsumerWidget {
  const MemberMembershipDetailDialog({
    super.key,
    required this.memberMembership,
    required this.memberId,
    required this.memberName,
  });

  final MemberMembership memberMembership;
  final String memberId;
  final String memberName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM dd, yyyy');
    final planAsync = ref.watch(
      membershipProvider(memberMembership.membershipId),
    );
    final addOnsAsync = ref.watch(
      memberMembershipAddOnsProvider(memberMembership.id),
    );

    final effectiveExpired =
        memberMembership.isExpired &&
        memberMembership.status == MemberMembershipStatus.active;
    final statusColor = effectiveExpired
        ? Colors.orange
        : _statusColor(memberMembership.status);

    final canRenew = planAsync.maybeWhen(
      data: (plan) =>
          plan != null &&
          plan.isActive &&
          memberMembership.status != MemberMembershipStatus.cancelled &&
          memberMembership.status != MemberMembershipStatus.voided,
      orElse: () => false,
    );

    // Do not wrap in Dialog — showConstrainedDialog already provides one.
    // A nested Dialog expands to max height and vertically centers content.
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: DialogConstraints.compactMaxWidth,
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Membership Details',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              memberName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            _InfoRow(
              label: 'Plan',
              value: memberMembership.membershipName ?? 'Membership',
            ),
            _InfoRow(
              label: 'Start Date',
              value: dateFormat.format(memberMembership.startDate),
            ),
            _InfoRow(
              label: 'End Date',
              value: dateFormat.format(memberMembership.endDate),
            ),
            _InfoRow(
              label: 'Status',
              value: effectiveExpired
                  ? 'Expired'
                  : memberMembership.status.displayName,
              valueColor: statusColor,
            ),
            if (memberMembership.isCurrentlyActive)
              _InfoRow(
                label: 'Days Remaining',
                value: '${memberMembership.daysRemaining}',
              ),
            planAsync.when(
              data: (plan) {
                if (plan == null) return const SizedBox.shrink();
                return _InfoRow(
                  label: 'Plan Price',
                  value: plan.price.toCurrency(),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            addOnsAsync.when(
              data: (addOns) {
                if (addOns.isEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add-Ons',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...addOns.map(
                        (addOn) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Expanded(child: Text(addOn.addOnName)),
                              Text(addOn.price.toCurrency()),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ),
                if (canRenew) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () async {
                        Navigator.of(context).pop();
                        if (!context.mounted) return;

                        await purchaseMembershipAndRecordPayment(
                          context,
                          ref,
                          memberId: memberId,
                          memberName: memberName,
                          preselectedMembershipId:
                              memberMembership.membershipId,
                          isRenewal: true,
                        );
                      },
                      icon: const Icon(Icons.autorenew),
                      label: const Text('Renew'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(MemberMembershipStatus status) {
    switch (status) {
      case MemberMembershipStatus.active:
        return Colors.green;
      case MemberMembershipStatus.expired:
        return Colors.orange;
      case MemberMembershipStatus.cancelled:
        return Colors.red;
      case MemberMembershipStatus.voided:
        return Colors.grey;
    }
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: valueColor != null ? FontWeight.w600 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
