import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/routes/members.routes.dart';
import '../../../../core/widgets/cached_avatar.dart';
import '../../../members/presentation/controllers/member_provider.dart';
import '../../../memberships/data/repositories/member_membership_repository.dart';
import '../../domain/check_in.dart';
import '../controllers/member_check_ins_controller.dart';

/// Sidebar panel showing details about the most recent check-in.
///
/// Displays: member avatar, name, membership info, check-in time,
/// and their recent check-in history.
class LastCheckInPanel extends ConsumerWidget {
  const LastCheckInPanel({super.key, required this.checkIn});

  final CheckIn checkIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final memberAsync = ref.watch(memberProvider(checkIn.memberId));
    final checkInsAsync =
        ref.watch(memberCheckInsProvider(checkIn.memberId));
    final membershipsAsync = ref.watch(
      memberActiveMembershipProvider(checkIn.memberId),
    );
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Last Check-in Details',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar
                memberAsync.when(
                  loading: () => CachedAvatar(radius: 40),
                  error: (_, __) => CachedAvatar(radius: 40),
                  data: (member) => CachedAvatar(
                    imageUrl: member?.photo,
                    radius: 40,
                  ),
                ),
                const SizedBox(height: 12),

                // Name
                Text(
                  checkIn.memberName ?? 'Unknown Member',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                // Membership info
                membershipsAsync.when(
                  loading: () => Text(
                    'Loading membership...',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (membership) => Text(
                    membership != null
                        ? 'Membership: ${membership.membershipName ?? 'Active'}'
                        : 'No Active Membership',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: membership != null
                          ? theme.colorScheme.onSurfaceVariant
                          : Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Check-in time
                Text(
                  'Checked in at ${timeFormat.format(checkIn.checkInTime)} Today',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                // Recent check-in history header
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'RECENT CHECK-IN HISTORY',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Check-in history list
                checkInsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  error: (_, __) => Text(
                    'Failed to load history',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  data: (checkIns) {
                    if (checkIns.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No check-in history',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    final displayCheckIns = checkIns.take(10).toList();

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayCheckIns.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 4),
                      itemBuilder: (context, index) {
                        final ci = displayCheckIns[index];
                        final isToday = _isToday(ci.checkInTime);

                        return _CheckInHistoryTile(
                          checkIn: ci,
                          dateFormat: dateFormat,
                          timeFormat: timeFormat,
                          isLatest: index == 0,
                          isToday: isToday,
                        );
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),

                // View Full Profile button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => MemberDetailRoute(
                      id: checkIn.memberId,
                    ).go(context),
                    child: const Text('View Full Profile'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }
}

/// A single check-in history entry with timeline-style indicator.
class _CheckInHistoryTile extends StatelessWidget {
  const _CheckInHistoryTile({
    required this.checkIn,
    required this.dateFormat,
    required this.timeFormat,
    required this.isLatest,
    required this.isToday,
  });

  final CheckIn checkIn;
  final DateFormat dateFormat;
  final DateFormat timeFormat;
  final bool isLatest;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dotColor = isLatest
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Date and details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateFormat.format(checkIn.checkInTime),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${checkIn.method.displayName} check-in',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Time
          Text(
            timeFormat.format(checkIn.checkInTime),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Provider that fetches the first active membership for a member.
/// Used by the sidebar to display membership info without a full controller.
final memberActiveMembershipProvider =
    FutureProvider.family.autoDispose((ref, String memberId) async {
  final repo = ref.read(memberMembershipRepositoryProvider);
  final result = await repo.fetchActive(memberId);
  return result.fold(
    (_) => null,
    (memberships) => memberships.isNotEmpty ? memberships.first : null,
  );
});
