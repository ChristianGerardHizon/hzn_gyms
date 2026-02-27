import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/routes/members.routes.dart';
import '../../../memberships/domain/member_membership.dart';
import '../controllers/expiring_memberships_controller.dart';

/// Section displaying memberships expiring within the next 7 days.
///
/// Shows member name, plan name, and days remaining.
/// Tapping a row navigates to the member detail page.
class ExpiringMembershipsSection extends ConsumerWidget {
  const ExpiringMembershipsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expiringAsync = ref.watch(expiringMembershipsProvider);

    return expiringAsync.when(
      data: (memberships) {
        if (memberships.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 20,
                    color: Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Expiring Memberships',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  Text(
                    '${memberships.length}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...memberships.map(
                (m) => _ExpiringMembershipTile(membership: m),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _ExpiringMembershipTile extends StatelessWidget {
  const _ExpiringMembershipTile({required this.membership});

  final MemberMembership membership;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = membership.daysRemaining;
    final dateFormat = DateFormat.MMMd();

    final Color urgencyColor;
    if (days <= 1) {
      urgencyColor = Colors.red;
    } else if (days <= 3) {
      urgencyColor = Colors.orange;
    } else {
      urgencyColor = Colors.amber.shade700;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            MemberDetailRoute(id: membership.memberId).go(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 36,
                decoration: BoxDecoration(
                  color: urgencyColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      membership.memberName ?? 'Unknown Member',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      membership.membershipName ?? 'Membership',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    days == 0
                        ? 'Today'
                        : days == 1
                            ? '1 day left'
                            : '$days days left',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: urgencyColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    dateFormat.format(membership.endDate),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
