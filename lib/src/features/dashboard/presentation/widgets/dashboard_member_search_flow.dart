import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../check_in/presentation/widgets/check_in_error_dialog.dart';
import '../../../members/presentation/widgets/member_picker_dialog.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import 'member_quick_view_dialog.dart';

/// Opens cross-branch member search from the dashboard, then renew/purchase at
/// the current branch or create a new member when no match is found.
Future<void> searchMemberFromDashboard(
  BuildContext context,
  WidgetRef ref,
) async {
  final branchId = ref.read(effectiveBranchIdForWriteProvider);
  if (branchId == null) {
    await showCheckInErrorDialog(
      context,
      title: 'Select a Branch',
      message:
          'Choose a specific branch before adding a membership. '
          '"All branches" cannot be used for this action.',
    );
    return;
  }

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
