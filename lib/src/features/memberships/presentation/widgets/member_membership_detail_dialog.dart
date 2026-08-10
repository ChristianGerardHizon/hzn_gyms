import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/permissions/current_user_permissions.dart';
import '../../../../core/routing/routes/sales_history.routes.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../../core/widgets/branch_code_pill.dart';
import '../../../../core/widgets/cached_avatar.dart';
import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../members/presentation/controllers/member_provider.dart';
import '../../../pos/domain/sale.dart';
import '../../../sales/presentation/controllers/sale_provider.dart';
import '../../../sales/presentation/widgets/sale_status_chip.dart';
import '../../../settings/presentation/controllers/branches_controller.dart';
import '../../domain/days_remaining_label.dart';
import '../../domain/member_membership.dart';
import '../../domain/membership_status_colors.dart';
import '../controllers/member_membership_add_ons_provider.dart';
import '../controllers/member_memberships_controller.dart';
import '../controllers/membership_provider.dart';
import 'edit_member_membership_dates_dialog.dart';
import 'purchase_membership_dialog.dart';

/// Shows details for a member's membership subscription.
///
/// When [showPhoto] is true, the member's profile photo is shown above the
/// name (used from check-in so staff can verify identity).
Future<void> showMemberMembershipDetailDialog(
  BuildContext context, {
  required MemberMembership memberMembership,
  required String memberId,
  required String memberName,
  bool showPhoto = false,
}) {
  return showConstrainedDialog<void>(
    context: context,
    maxWidth: DialogConstraints.compactMaxWidth,
    barrierDismissible: true,
    builder: (context) => MemberMembershipDetailDialog(
      memberMembership: memberMembership,
      memberId: memberId,
      memberName: memberName,
      showPhoto: showPhoto,
    ),
  );
}

class MemberMembershipDetailDialog extends ConsumerWidget {
  const MemberMembershipDetailDialog({
    super.key,
    required this.memberMembership,
    required this.memberId,
    required this.memberName,
    this.showPhoto = false,
  });

  final MemberMembership memberMembership;
  final String memberId;
  final String memberName;
  final bool showPhoto;

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
    final branches = ref.watch(branchesControllerProvider).value ?? const [];
    final branchPill = BranchCodePill.fromBranches(
      branchId: memberMembership.branchId,
      branches: branches,
      dense: true,
    );
    final canEdit =
        ref.watch(currentUserPermissionsProvider).value?.canEditMemberships ??
        false;

    final effectiveExpired =
        memberMembership.isExpired &&
        memberMembership.status == MemberMembershipStatus.active;
    final statusColor = membershipStatusColor(
      memberMembership.status,
      effectiveExpired: effectiveExpired,
    );

    final canRenew = planAsync.maybeWhen(
      data: (plan) =>
          plan != null &&
          plan.isActive &&
          memberMembership.status != MemberMembershipStatus.cancelled &&
          memberMembership.status != MemberMembershipStatus.voided,
      orElse: () => false,
    );

    final canEditDates =
        canEdit && memberMembership.status != MemberMembershipStatus.voided;
    final canCancel =
        canEdit &&
        (memberMembership.status == MemberMembershipStatus.active ||
            memberMembership.status == MemberMembershipStatus.expired);

    // Do not wrap in Dialog — showConstrainedDialog already provides one.
    // A nested Dialog expands to max height and vertically centers content.
    return ScaffoldMessenger(
      child: Builder(
        builder: (context) {
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
                  if (showPhoto) ...[
                    Center(
                      child: ref.watch(memberProvider(memberId)).when(
                        loading: () => const CachedAvatar(radius: 48),
                        error: (_, __) => const CachedAvatar(radius: 48),
                        data: (member) => CachedAvatar(
                          imageUrl: member?.photo,
                          radius: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    memberName,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: showPhoto ? TextAlign.center : TextAlign.start,
                  ),
                  const SizedBox(height: 20),
                  _InfoRow(
                    label: 'Plan',
                    value: memberMembership.membershipName ?? 'Membership',
                  ),
                  if (branchPill != null)
                    _InfoRow(
                      label: 'Branch',
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: branchPill,
                      ),
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
                      value: formatDaysRemainingLabel(
                        memberMembership.daysRemaining,
                      ),
                      valueColor: membershipLifecycleColor(
                        daysRemaining: memberMembership.daysRemaining,
                      ),
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
                  if (_hasLinkedSale(memberMembership.saleId))
                    _LinkedSaleSection(saleId: memberMembership.saleId!),
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
                  if (canEditDates || canCancel) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (canEditDates)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () async {
                                final updated =
                                    await showEditMemberMembershipDatesDialog(
                                      context,
                                      memberMembership: memberMembership,
                                    );
                                if (updated == true && context.mounted) {
                                  Navigator.of(context).pop();
                                }
                              },
                              icon: const Icon(Icons.edit_calendar),
                              label: const Text('Edit Dates'),
                            ),
                          ),
                        if (canEditDates && canCancel)
                          const SizedBox(width: 12),
                        if (canCancel)
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _confirmCancel(
                                context,
                                ref,
                                memberId: memberId,
                                memberMembershipId: memberMembership.id,
                              ),
                              icon: Icon(
                                Icons.cancel_outlined,
                                color: theme.colorScheme.error,
                              ),
                              label: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
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
                              // Close detail first so renew/payment are not
                              // stacked under this modal. Use the navigator
                              // context — this dialog's ref/context die on pop.
                              final navigator = Navigator.of(context);
                              navigator.pop();
                              if (!navigator.mounted) return;

                              await purchaseMembershipAndRecordPayment(
                                navigator.context,
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
        },
      ),
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    WidgetRef ref, {
    required String memberId,
    required String memberMembershipId,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Membership'),
        content: const Text(
          'Are you sure you want to cancel this membership? '
          'This sets the status to cancelled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Cancel Membership'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final error = await ref
        .read(memberMembershipsControllerProvider(memberId).notifier)
        .cancelMembership(memberMembershipId);

    if (!context.mounted) return;

    if (error != null) {
      showErrorSnackBar(context, message: error, useRootMessenger: false);
      return;
    }

    Navigator.of(context).pop();
    showSuccessSnackBar(context, message: 'Membership cancelled');
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    this.value,
    this.child,
    this.valueColor,
  }) : assert(value != null || child != null);

  final String label;
  final String? value;
  final Widget? child;
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
            child: child ??
                Text(
                  value!,
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

bool _hasLinkedSale(String? saleId) {
  final id = saleId?.trim();
  return id != null && id.isNotEmpty;
}

/// Loads and displays the sale linked to a membership, if any.
class _LinkedSaleSection extends ConsumerWidget {
  const _LinkedSaleSection({required this.saleId});

  final String saleId;

  void _openSale(BuildContext context) {
    final router = GoRouter.of(context);
    final location = SaleDetailRoute(id: saleId).location;
    Navigator.of(context).pop();
    router.push(location);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final saleAsync = ref.watch(saleProvider(saleId));

    return _InfoRow(
      label: 'Sale',
      child: saleAsync.when(
        loading: () => Text(
          'Loading…',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        error: (_, __) => _LinkedSaleTapTarget(
          onTap: () => _openSale(context),
          child: Text(
            'View linked sale',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        data: (sale) {
          if (sale == null) {
            return Text(
              'Sale unavailable',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            );
          }

          return _LinkedSaleTapTarget(
            onTap: () => _openSale(context),
            child: _LinkedSaleSummary(sale: sale),
          );
        },
      ),
    );
  }
}

class _LinkedSaleTapTarget extends StatelessWidget {
  const _LinkedSaleTapTarget({
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: child,
        ),
      ),
    );
  }
}

class _LinkedSaleSummary extends StatelessWidget {
  const _LinkedSaleSummary({required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          Icons.receipt_long,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sale.receiptNumber.isNotEmpty
                    ? sale.receiptNumber
                    : sale.shortReceiptNumber,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sale.totalAmount.toCurrency(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SaleStatusChip(status: sale.status, dense: true, showLabel: true),
        const SizedBox(width: 4),
        Icon(
          Icons.chevron_right,
          size: 20,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ],
    );
  }
}
