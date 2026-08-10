import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/permissions/current_user_permissions.dart';
import '../../../../core/widgets/branch_code_pill.dart';
import '../../../../core/widgets/cached_avatar.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../../members/presentation/controllers/member_provider.dart';
import '../../../settings/domain/branch.dart';
import '../../../settings/presentation/controllers/branches_controller.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../controllers/check_in_controller.dart';
import '../../domain/check_in.dart';
import 'last_check_in_panel.dart';
import 'void_check_in_dialog.dart';

/// Widget displaying today's recent check-ins.
class RecentCheckInsList extends ConsumerWidget {
  const RecentCheckInsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInsAsync = ref.watch(checkInControllerProvider);
    final theme = Theme.of(context);
    final timeFormat = DateFormat('hh:mm a');
    final viewingAll = ref.watch(viewingAllBranchesProvider);
    final branches = ref.watch(branchesControllerProvider).value ?? const [];
    final canVoid =
        ref.watch(currentUserPermissionsProvider).value?.canVoidCheckIns ??
        false;

    return checkInsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorState.fromError(
        error,
        onRetry: () => ref.read(checkInControllerProvider.notifier).refresh(),
      ),
      data: (checkIns) {
        if (checkIns.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.how_to_reg_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.3,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No check-ins today',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(checkInControllerProvider.notifier).refresh(),
          child: ListView.separated(
            itemCount: checkIns.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final checkIn = checkIns[index];
              return _CheckInListTile(
                checkIn: checkIn,
                timeFormat: timeFormat,
                showBranch: viewingAll,
                branches: branches,
                canVoid: canVoid,
              );
            },
          ),
        );
      },
    );
  }
}

class _CheckInListTile extends ConsumerWidget {
  const _CheckInListTile({
    required this.checkIn,
    required this.timeFormat,
    required this.showBranch,
    required this.branches,
    required this.canVoid,
  });

  final CheckIn checkIn;
  final DateFormat timeFormat;
  final bool showBranch;
  final List<Branch> branches;
  final bool canVoid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final memberAsync = ref.watch(memberProvider(checkIn.memberId));
    final branchPill = showBranch
        ? BranchCodePill.fromBranches(
            branchId: checkIn.branchId,
            branches: branches,
            dense: true,
          )
        : null;

    return ListTile(
      leading: CachedAvatar(
        imageUrl: memberAsync.value?.photo,
        radius: 20,
        thumbSize: 80,
      ),
      title: Text(checkIn.memberName ?? 'Unknown Member'),
      subtitle: Row(
        children: [
          Flexible(
            child: Text(
              '${timeFormat.format(checkIn.checkInTime)} - ${checkIn.method.displayName}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (branchPill != null) ...[const SizedBox(width: 6), branchPill],
        ],
      ),
      trailing: canVoid
          ? IconButton(
              tooltip: 'Void check-in',
              icon: const Icon(Icons.undo),
              onPressed: () =>
                  showVoidCheckInDialog(context, ref, checkIn: checkIn),
            )
          : null,
      onTap: () => showActiveMembershipFromCheckIn(
        context,
        ref,
        memberId: checkIn.memberId,
        memberName: checkIn.memberName ?? 'Unknown Member',
      ),
    );
  }
}
