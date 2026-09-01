import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/permissions/current_user_permissions.dart';
import '../../../../core/widgets/select_branch_for_action_dialog.dart';
import '../../../check_in/domain/card_check_in_result.dart';
import '../../../check_in/domain/check_in_block_reason.dart';
import '../../../check_in/domain/check_in_cooldown.dart';
import '../../../check_in/domain/manual_check_in_result.dart';
import '../../../check_in/presentation/controllers/check_in_controller.dart';
import '../../../check_in/presentation/widgets/check_in_error_dialog.dart';
import '../../../check_in/presentation/widgets/check_in_success_dialog.dart';
import '../../../members/presentation/widgets/member_picker_dialog.dart';
import '../../../memberships/data/repositories/member_membership_repository.dart';
import '../../../pos/data/repositories/sales_repository.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../../users/domain/user_role.dart';

const _cashierCheckInNeedsBranchMessage =
    'Check-in cannot be done while viewing all branches. '
    'Select a branch first.';

/// Compact check-in controls for the cashier dialog.
///
/// Manual / card-ID only — does **not** mount [CheckInRfidListener]
/// (Dashboard already owns RFID while this dialog is open).
class CashierCheckInStrip extends HookConsumerWidget {
  const CashierCheckInStrip({super.key, this.dense = false});

  final bool dense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canCreate =
        ref
            .watch(currentUserPermissionsProvider)
            .value
            ?.has(Permissions.checkInsCreate) ??
        false;
    if (!canCreate) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final cardController = useTextEditingController();
    final isBusy = useState(false);

    Future<void> checkInSelectedMember() async {
      final hasBranch = await ensureWritableBranch(
        context,
        ref,
        message: _cashierCheckInNeedsBranchMessage,
      );
      if (!hasBranch || !context.mounted) return;

      final member = await showMemberPickerDialog(
        context,
        title: 'Check In Member',
        subtitle: 'Select a member to check in',
      );
      if (member == null || !context.mounted) return;

      final branchId = ref.read(effectiveBranchIdForWriteProvider);
      if (branchId == null) return;

      isBusy.value = true;
      final mmRepo = ref.read(memberMembershipRepositoryProvider);
      final mmResult = await mmRepo.fetchActive(member.id);
      final resolution = await mmResult.fold(
        (_) async => resolveCheckInMembership(
          activeMemberships: const [],
          branchId: branchId,
          salesRepo: ref.read(salesRepositoryProvider),
        ),
        (memberships) => resolveCheckInMembership(
          activeMemberships: memberships,
          branchId: branchId,
          salesRepo: ref.read(salesRepositoryProvider),
        ),
      );

      if (!resolution.isAllowed) {
        isBusy.value = false;
        if (!context.mounted) return;
        final reason =
            resolution.reason ?? CheckInBlockReason.noActiveMembership;
        await showCheckInErrorDialog(
          context,
          title: checkInBlockTitle(reason),
          message: checkInBlockMessage(reason, member.name),
        );
        return;
      }

      final result = await ref
          .read(checkInControllerProvider.notifier)
          .manualCheckIn(
            memberId: member.id,
            memberMembershipId: resolution.membership?.id,
          );
      isBusy.value = false;
      if (!context.mounted) return;

      switch (result) {
        case ManualCheckInSuccess():
          final membership = resolution.membership;
          await showCheckInSuccessDialog(
            context,
            memberName: member.name,
            hasActiveMembership: membership != null,
            membershipName: membership?.membershipName,
            membershipEndDate: membership?.endDate,
            membershipDaysRemaining: membership?.daysRemaining,
            memberPhotoUrl: member.photo,
          );
        case ManualCheckInCooldown(:final remaining):
          await showCheckInErrorDialog(
            context,
            title: 'Check-In Too Soon',
            message: checkInCooldownMessage(remaining),
          );
        case ManualCheckInNoBranch():
          await showCheckInErrorDialog(
            context,
            title: 'Branch Required',
            message: _cashierCheckInNeedsBranchMessage,
          );
        case ManualCheckInFailed():
          await showCheckInErrorDialog(
            context,
            title: 'Check-In Failed',
            message: 'Could not record check-in. Try again.',
          );
      }
    }

    Future<void> checkInByCard() async {
      final cardValue = cardController.text.trim();
      if (cardValue.isEmpty) return;

      final hasBranch = await ensureWritableBranch(
        context,
        ref,
        message: _cashierCheckInNeedsBranchMessage,
      );
      if (!hasBranch || !context.mounted) return;

      isBusy.value = true;
      final result = await ref
          .read(checkInControllerProvider.notifier)
          .cardCheckIn(cardValue: cardValue);
      isBusy.value = false;
      if (!context.mounted) return;

      switch (result) {
        case CardCheckInSuccess(
          :final memberName,
          :final membershipName,
          :final membershipEndDate,
          :final membershipDaysRemaining,
          :final memberPhoto,
        ):
          cardController.clear();
          await showCheckInSuccessDialog(
            context,
            memberName: memberName,
            hasActiveMembership: true,
            membershipName: membershipName,
            membershipEndDate: membershipEndDate,
            membershipDaysRemaining: membershipDaysRemaining,
            memberPhotoUrl: memberPhoto,
          );
        case CardCheckInCardNotFound():
          await showCheckInErrorDialog(
            context,
            title: 'Card Not Found',
            message:
                'No member matches card "$cardValue". '
                'Check that the card is registered.',
          );
        case CardCheckInNoActiveMembership(:final memberName):
          await showCheckInErrorDialog(
            context,
            title: checkInBlockTitle(CheckInBlockReason.noActiveMembership),
            message: checkInBlockMessage(
              CheckInBlockReason.noActiveMembership,
              memberName,
            ),
          );
        case CardCheckInUnpaidMembership(:final memberName):
          await showCheckInErrorDialog(
            context,
            title: checkInBlockTitle(CheckInBlockReason.unpaidMembership),
            message: checkInBlockMessage(
              CheckInBlockReason.unpaidMembership,
              memberName,
            ),
          );
        case CardCheckInMembershipNotValidAtBranch(:final memberName):
          await showCheckInErrorDialog(
            context,
            title: checkInBlockTitle(CheckInBlockReason.notValidAtBranch),
            message: checkInBlockMessage(
              CheckInBlockReason.notValidAtBranch,
              memberName,
            ),
          );
        case CardCheckInNoBranch():
          await showCheckInErrorDialog(
            context,
            title: 'Branch Required',
            message: _cashierCheckInNeedsBranchMessage,
          );
        case CardCheckInFailed():
          await showCheckInErrorDialog(
            context,
            title: 'Check-In Failed',
            message: 'Could not record check-in. Try again.',
          );
        case CardCheckInCooldown(:final remaining):
          await showCheckInErrorDialog(
            context,
            title: 'Check-In Too Soon',
            message: checkInCooldownMessage(remaining),
          );
      }
    }

    final pad = dense ? 8.0 : 12.0;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      child: Padding(
        padding: EdgeInsets.fromLTRB(pad, dense ? 6 : 8, pad, dense ? 6 : 8),
        child: Row(
          children: [
            Icon(
              Icons.how_to_reg_outlined,
              size: dense ? 20 : 22,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              'Check-in',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: isBusy.value ? null : checkInSelectedMember,
              child: const Text('Member'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: cardController,
                enabled: !isBusy.value,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Card ID',
                  border: const OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: dense ? 8 : 10,
                  ),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => checkInByCard(),
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Check in by card',
              onPressed: isBusy.value ? null : checkInByCard,
              icon: isBusy.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.login),
            ),
          ],
        ),
      ),
    );
  }
}
