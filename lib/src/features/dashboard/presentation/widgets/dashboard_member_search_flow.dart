import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/select_branch_for_action_dialog.dart';
import '../../../members/presentation/widgets/member_picker_dialog.dart';
import 'member_quick_view_dialog.dart';

const _dashboardNeedsBranchMessage =
    'Choose a specific branch before adding a membership. '
    'This action cannot be done while viewing all branches.';

/// Opens cross-branch member search from the dashboard, then renew/purchase at
/// the current branch or create a new member when no match is found.
Future<void> searchMemberFromDashboard(
  BuildContext context,
  WidgetRef ref,
) async {
  final hasBranch = await ensureWritableBranch(
    context,
    ref,
    message: _dashboardNeedsBranchMessage,
  );
  if (!hasBranch || !context.mounted) return;

  final member = await showMemberPickerDialog(
    context,
    title: 'Search Member',
    subtitle: 'Search all branches — membership will be added at this branch',
    showBranchActivity: true,
    allowCreateOnEmpty: true,
  );
  if (!context.mounted) return;

  if (member != null) {
    await showMemberQuickViewDialog(context, memberId: member.id);
  }

  // Picker handles "Create new member" internally when no match is found.
}
