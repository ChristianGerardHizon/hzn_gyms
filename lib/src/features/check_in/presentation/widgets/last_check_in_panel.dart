import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/routes/members.routes.dart';
import '../../../../core/widgets/cached_avatar.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../members/domain/member.dart';
import '../../../members/presentation/controllers/member_provider.dart';
import '../../../memberships/data/repositories/member_membership_repository.dart';
import '../../../memberships/domain/member_membership.dart';
import '../../../memberships/presentation/widgets/member_membership_detail_dialog.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/check_in.dart';
import '../../domain/check_in_membership_eligibility.dart';
import '../../domain/check_in_membership_highlight.dart';
import '../controllers/member_check_ins_controller.dart';

/// Opens the active membership detail modal for a member, or shows info when
/// there is no active membership.
Future<void> showActiveMembershipFromCheckIn(
  BuildContext context,
  WidgetRef ref, {
  required String memberId,
  required String memberName,
}) async {
  // Keep the autoDispose provider alive for the duration of this await so a
  // mid-fetch dispose does not complete as null and flash "No active membership".
  final subscription = ref.listenManual(
    memberActiveMembershipProvider(memberId),
    (_, __) {},
  );
  try {
    final membership = await ref.read(
      memberActiveMembershipProvider(memberId).future,
    );
    if (!context.mounted) return;

    if (membership == null) {
      showInfoSnackBar(context, message: 'No active membership');
      return;
    }

    await showMemberMembershipDetailDialog(
      context,
      memberMembership: membership,
      memberId: memberId,
      memberName: memberName,
      showPhoto: true,
    );
  } on MemberActiveMembershipCancelled {
    return;
  } finally {
    subscription.close();
  }
}

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
    final checkInsAsync = ref.watch(memberCheckInsProvider(checkIn.memberId));
    final membershipsAsync = ref.watch(
      memberActiveMembershipProvider(checkIn.memberId),
    );
    final timeFormat = DateFormat('hh:mm a');
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 24,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Text(
                'Last Check-in Details',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _MembershipStatusProfileBlock(
                  theme: theme,
                  checkIn: checkIn,
                  memberAsync: memberAsync,
                  membershipsAsync: membershipsAsync,
                  timeFormat: timeFormat,
                  onTap: () => showActiveMembershipFromCheckIn(
                    context,
                    ref,
                    memberId: checkIn.memberId,
                    memberName: checkIn.memberName ?? 'Unknown Member',
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Recent check-in history header
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'RECENT CHECK-IN HISTORY',
                    style: theme.textTheme.labelMedium?.copyWith(
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
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                  data: (checkIns) {
                    if (checkIns.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No check-in history',
                          style: theme.textTheme.bodyMedium?.copyWith(
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
                      separatorBuilder: (_, __) => const SizedBox(height: 4),
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

                const SizedBox(height: 20),

                // View Full Profile button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: theme.textTheme.titleSmall,
                    ),
                    onPressed: () =>
                        MemberDetailRoute(id: checkIn.memberId).go(context),
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

/// Profile block with membership-status background tint.
class _MembershipStatusProfileBlock extends StatelessWidget {
  const _MembershipStatusProfileBlock({
    required this.theme,
    required this.checkIn,
    required this.memberAsync,
    required this.membershipsAsync,
    required this.timeFormat,
    this.onTap,
  });

  final ThemeData theme;
  final CheckIn checkIn;
  final AsyncValue<Member?> memberAsync;
  final AsyncValue<MemberMembership?> membershipsAsync;
  final DateFormat timeFormat;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final highlight = membershipsAsync.whenOrNull(
      data: resolveCheckInMembershipHighlight,
    );
    final statusColor = highlight != null
        ? _highlightColor(highlight)
        : null;

    final content = Column(
      children: [
        memberAsync.when(
          loading: () => const CachedAvatar(radius: 56),
          error: (_, __) => const CachedAvatar(radius: 56),
          data: (member) =>
              CachedAvatar(imageUrl: member?.photo, radius: 56),
        ),
        const SizedBox(height: 16),
        Text(
          checkIn.memberName ?? 'Unknown Member',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        membershipsAsync.when(
          loading: () => Text(
            'Loading membership...',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
          data: (membership) => Text(
            membership != null
                ? 'Membership: ${membership.membershipName ?? 'Active'}'
                : 'No Active Membership',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: membership != null
                  ? theme.colorScheme.onSurfaceVariant
                  : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Checked in at ${timeFormat.format(checkIn.checkInTime)} Today',
          style: theme.textTheme.titleSmall?.copyWith(
            color: statusColor ?? theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final padded = statusColor == null
        ? Padding(
            padding: const EdgeInsets.all(20),
            child: content,
          )
        : Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: content,
          );

    if (onTap == null) return padded;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: padded,
      ),
    );
  }
}

Color _highlightColor(CheckInMembershipHighlight highlight) {
  return switch (highlight) {
    CheckInMembershipHighlight.active => Colors.green,
    CheckInMembershipHighlight.nearExpiry => Colors.orange,
    CheckInMembershipHighlight.expired => Colors.red,
  };
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isToday ? theme.colorScheme.primary : dotColor,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Date and details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        dateFormat.format(checkIn.checkInTime),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 8),
                      Text(
                        'TODAY',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${checkIn.method.displayName} check-in',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Time
          Text(
            timeFormat.format(checkIn.checkInTime),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Thrown when [memberActiveMembershipProvider] is disposed mid-fetch.
///
/// Callers must not treat this as "no active membership".
class MemberActiveMembershipCancelled implements Exception {
  const MemberActiveMembershipCancelled();
}

/// Provider that fetches the first active membership for a member
/// that is valid at the current branch and paid if linked to a sale.
/// Used by the sidebar to display membership info without a full controller.
final memberActiveMembershipProvider = FutureProvider.family.autoDispose((
  ref,
  String memberId,
) async {
  final branchId = ref.watch(effectiveBranchIdForWriteProvider);
  final repo = ref.read(memberMembershipRepositoryProvider);
  final salesRepo = ref.read(salesRepositoryProvider);

  final result = await repo.fetchActive(memberId, validAtBranchId: branchId);
  if (!ref.mounted) throw const MemberActiveMembershipCancelled();

  final memberships = result.fold(
    (_) => <MemberMembership>[],
    (list) => list,
  );
  final eligible = await filterCheckInEligibleMemberships(
    memberships: memberships,
    salesRepo: salesRepo,
  );
  if (!ref.mounted) throw const MemberActiveMembershipCancelled();

  return eligible.isNotEmpty ? eligible.first : null;
});
