import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/routing/routes/members.routes.dart';
import '../../../../core/widgets/cached_avatar.dart';
import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/dialog_close_handler.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../../member_cards/presentation/controllers/member_cards_controller.dart';
import '../../../member_cards/presentation/widgets/add_card_dialog.dart';
import '../../../members/domain/member.dart';
import '../../../members/presentation/controllers/member_branch_activity_controller.dart';
import '../../../members/presentation/controllers/member_provider.dart';
import '../../../members/presentation/widgets/member_branch_activity_chips.dart';
import '../../../memberships/domain/days_remaining_label.dart';
import '../../../memberships/domain/member_branch_activity.dart';
import '../../../memberships/domain/member_membership.dart';
import '../../../memberships/domain/membership_status_colors.dart';
import '../../../memberships/domain/pick_renewable_membership.dart';
import '../../../memberships/presentation/controllers/member_memberships_controller.dart';
import '../../../memberships/presentation/widgets/purchase_membership_dialog.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../controllers/dashboard_members_controller.dart';

/// Shows a quick-view dialog with member details and membership summary.
///
/// Used from the dashboard member grid for fast lookup without navigating
/// to the full member detail page.
Future<void> showMemberQuickViewDialog(
  BuildContext context, {
  required String memberId,
  DashboardMember? dashboardMember,
}) {
  return showConstrainedDialog<void>(
    context: context,
    maxWidth: DialogConstraints.compactMaxWidth,
    barrierDismissible: true,
    builder: (context) => MemberQuickViewDialog(
      memberId: memberId,
      dashboardMember: dashboardMember,
    ),
  );
}

/// Compact member + membership preview dialog for the dashboard.
class MemberQuickViewDialog extends ConsumerWidget {
  const MemberQuickViewDialog({
    super.key,
    required this.memberId,
    this.dashboardMember,
  });

  final String memberId;
  final DashboardMember? dashboardMember;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d, yyyy');
    final branchId = ref.watch(effectiveBranchIdForWriteProvider);
    final memberAsync = ref.watch(memberProvider(memberId));
    final membershipsAsync =
        ref.watch(memberMembershipsControllerProvider(memberId));
    final activityAsync = ref.watch(
      memberBranchActivityForIdsProvider(memberBranchActivityIdsKey([memberId])),
    );

    final fallbackName = dashboardMember?.name ?? 'Member';
    final fallbackPhoto = dashboardMember?.photo;
    final fallbackMobile = dashboardMember?.mobileNumber;

    return DialogCloseHandler(
      child: ConstrainedDialogContent(
        maxWidth: DialogConstraints.compactMaxWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Expanded(
                    child: Text(
                      'Member',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    memberAsync.when(
                      loading: () => _MemberHeader(
                        name: fallbackName,
                        photoUrl: fallbackPhoto,
                        mobileNumber: fallbackMobile,
                        isLoading: true,
                      ),
                      error: (_, __) => _MemberHeader(
                        name: fallbackName,
                        photoUrl: fallbackPhoto,
                        mobileNumber: fallbackMobile,
                      ),
                      data: (member) {
                        if (member == null) {
                          return _MemberHeader(
                            name: fallbackName,
                            photoUrl: fallbackPhoto,
                            mobileNumber: fallbackMobile,
                          );
                        }
                        return _MemberDetailsSection(
                          member: member,
                          dateFormat: dateFormat,
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Membership',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    membershipsAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      error: (error, _) =>
                          ErrorState.fromError(error, compact: true),
                      data: (memberships) => _MembershipSummary(
                        memberships: memberships,
                        dateFormat: dateFormat,
                        dashboardMember: dashboardMember,
                        branchId: branchId,
                        branchActivity: activityAsync.maybeWhen(
                          data: (state) =>
                              state.activityByMemberId[memberId],
                          orElse: () => null,
                        ),
                        branchCodeById: activityAsync.maybeWhen(
                          data: (state) => state.branchCodeById,
                          orElse: () => const {},
                        ),
                        branchNameById: activityAsync.maybeWhen(
                          data: (state) => state.branchNameById,
                          orElse: () => const {},
                        ),
                        branchColorById: activityAsync.maybeWhen(
                          data: (state) => state.branchColorById,
                          orElse: () => const {},
                        ),
                        activityLoading: activityAsync.isLoading,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: membershipsAsync.when(
                loading: () => _ActionButtons(
                  memberId: memberId,
                  memberName: fallbackName,
                  renewableMembership: null,
                  membershipsLoaded: false,
                  branchId: branchId,
                ),
                error: (_, __) => _ActionButtons(
                  memberId: memberId,
                  memberName: fallbackName,
                  renewableMembership: null,
                  membershipsLoaded: true,
                  branchId: branchId,
                ),
                data: (memberships) {
                  final name = memberAsync.maybeWhen(
                    data: (m) => m?.name ?? fallbackName,
                    orElse: () => fallbackName,
                  );
                  final renewable = branchId != null
                      ? pickRenewableMembershipAtBranch(
                          memberships,
                          branchId,
                        )
                      : pickRenewableMembership(memberships);
                  return _ActionButtons(
                    memberId: memberId,
                    memberName: name,
                    renewableMembership: renewable,
                    membershipsLoaded: true,
                    branchId: branchId,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberHeader extends StatelessWidget {
  const _MemberHeader({
    required this.name,
    this.photoUrl,
    this.mobileNumber,
    this.isLoading = false,
  });

  final String name;
  final String? photoUrl;
  final String? mobileNumber;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        CachedAvatar(imageUrl: photoUrl, radius: 36, thumbSize: 120),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (mobileNumber != null && mobileNumber!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  mobileNumber!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (isLoading) ...[
                const SizedBox(height: 8),
                Text(
                  'Loading details…',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MemberDetailsSection extends StatelessWidget {
  const _MemberDetailsSection({
    required this.member,
    required this.dateFormat,
  });

  final Member member;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MemberHeader(
          name: member.name,
          photoUrl: member.photo,
          mobileNumber: member.mobileNumber,
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        const SizedBox(height: 12),
        if (member.email != null && member.email!.isNotEmpty)
          _InfoRow(label: 'Email', value: member.email!),
        if (member.dateOfBirth != null)
          _InfoRow(
            label: 'Date of Birth',
            value: dateFormat.format(member.dateOfBirth!),
          ),
        if (member.sex != null)
          _InfoRow(label: 'Sex', value: member.sex!.displayName),
        if (member.address != null && member.address!.isNotEmpty)
          _InfoRow(label: 'Address', value: member.address!),
        if (member.emergencyContact != null &&
            member.emergencyContact!.isNotEmpty)
          _InfoRow(
            label: 'Emergency Contact',
            value: member.emergencyContact!,
          ),
        if (member.remarks != null && member.remarks!.isNotEmpty)
          _InfoRow(label: 'Remarks', value: member.remarks!),
        if (_hasNoExtraDetails(member))
          Text(
            'No additional contact details on file',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  bool _hasNoExtraDetails(Member member) {
    return (member.email == null || member.email!.isEmpty) &&
        member.dateOfBirth == null &&
        member.sex == null &&
        (member.address == null || member.address!.isEmpty) &&
        (member.emergencyContact == null ||
            member.emergencyContact!.isEmpty) &&
        (member.remarks == null || member.remarks!.isEmpty);
  }
}

class _MembershipSummary extends StatelessWidget {
  const _MembershipSummary({
    required this.memberships,
    required this.dateFormat,
    this.dashboardMember,
    this.branchId,
    this.branchActivity,
    this.branchCodeById = const {},
    this.branchNameById = const {},
    this.branchColorById = const {},
    this.activityLoading = false,
  });

  final List<MemberMembership> memberships;
  final DateFormat dateFormat;
  final DashboardMember? dashboardMember;
  final String? branchId;
  final MemberBranchActivity? branchActivity;
  final Map<String, String> branchCodeById;
  final Map<String, String> branchNameById;
  final Map<String, String> branchColorById;
  final bool activityLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = branchId != null
        ? pickRenewableMembershipAtBranch(memberships, branchId!)
        : pickRenewableMembership(memberships);

    if (primary == null) {
      final hasActivityElsewhere =
          branchActivity != null && !branchActivity!.isEmpty;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.card_membership_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branchId != null
                            ? 'No membership at this branch'
                            : 'No membership',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (hasActivityElsewhere)
                        Text(
                          'Active at other branches',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      else if (dashboardMember?.expirationDate != null)
                        Text(
                          'Last seen expiry: ${dateFormat.format(dashboardMember!.expirationDate!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      else
                        Text(
                          'Purchase a plan to grant access at this branch',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (branchId != null) ...[
              const SizedBox(height: 12),
              MemberBranchActivityChips(
                activity: branchActivity,
                branchCodeById: branchCodeById,
                branchNameById: branchNameById,
                branchColorById: branchColorById,
                currentBranchId: branchId,
                isLoading: activityLoading,
              ),
            ],
          ],
        ),
      );
    }

    final effectiveExpired =
        primary.isExpired && primary.status == MemberMembershipStatus.active;
    final statusLabel =
        effectiveExpired ? 'Expired' : primary.status.displayName;
    final statusColor = membershipStatusColor(
      primary.status,
      effectiveExpired: effectiveExpired,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: statusColor.withValues(alpha: 0.15),
                child: Icon(
                  Icons.card_membership,
                  size: 18,
                  color: statusColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  primary.membershipName ?? 'Membership',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Period',
            value:
                '${dateFormat.format(primary.startDate)} – ${dateFormat.format(primary.endDate)}',
          ),
          if (primary.isCurrentlyActive)
            _InfoRow(
              label: 'Days left',
              value: formatDaysRemainingLabel(primary.daysRemaining),
              valueColor: membershipLifecycleColor(
                daysRemaining: primary.daysRemaining,
              ),
            )
          else if (effectiveExpired ||
              primary.status == MemberMembershipStatus.expired)
            _InfoRow(
              label: 'Expired',
              value: dateFormat.format(primary.endDate),
              valueColor: statusColor,
            ),
          if (memberships.length > 1) ...[
            const SizedBox(height: 4),
            Text(
              '+${memberships.length - 1} more membership'
              '${memberships.length - 1 == 1 ? '' : 's'}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButtons extends ConsumerWidget {
  const _ActionButtons({
    required this.memberId,
    required this.memberName,
    required this.renewableMembership,
    required this.membershipsLoaded,
    this.branchId,
  });

  final String memberId;
  final String memberName;
  final MemberMembership? renewableMembership;
  final bool membershipsLoaded;
  final String? branchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasRenewable = renewableMembership != null;
    final renewLabel = hasRenewable ? 'Renew membership' : 'Purchase membership';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton.icon(
          onPressed: !membershipsLoaded || branchId == null
              ? null
              : () async {
                  // Close quick-view first so purchase/payment are not stacked
                  // under the member modal (same pattern as membership detail).
                  // Use the navigator context — this dialog's ref/context die
                  // on pop; ProviderContainer is taken from the new context.
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  if (!navigator.mounted) return;

                  await purchaseMembershipAndRecordPayment(
                    navigator.context,
                    memberId: memberId,
                    memberName: memberName,
                    preselectedMembershipId:
                        renewableMembership?.membershipId,
                    isRenewal: hasRenewable,
                  );
                },
          icon: Icon(hasRenewable ? Icons.autorenew : Icons.add),
          label: Text(renewLabel),
        ),
        const SizedBox(height: 8),
        FilledButton.tonalIcon(
          onPressed: () async {
            final result = await showAddCardDialog(
              context,
              memberId: memberId,
            );
            if (result == true) {
              ref.invalidate(memberCardsControllerProvider(memberId));
            }
          },
          icon: const Icon(Icons.credit_card),
          label: const Text('Add Card'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            // Root-navigator dialogs sit outside RouteBase.builder, so
            // GoRouterState.of(context) throws. Read the org/branch scope
            // from the router's current path instead, mirroring
            // `OrgScopedGoRouteData._scopedLocation`.
            final router = GoRouter.of(context);
            final segments = router.state.uri.pathSegments;
            final memberLocation = MemberDetailRoute(id: memberId).location;
            final location = segments.length >= 2
                ? '/${segments[0]}/${segments[1]}$memberLocation'
                : memberLocation;
            // Close stacked dialogs (e.g. KPI list + quick view) before leaving.
            Navigator.of(context, rootNavigator: true).popUntil(
              (route) => route is! PopupRoute,
            );
            router.push(location);
          },
          icon: const Icon(Icons.open_in_new),
          label: const Text('Show full details'),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
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
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
