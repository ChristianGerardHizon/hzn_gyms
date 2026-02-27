import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/breakpoints.dart';
import '../widgets/tablet_members_layout.dart';

/// Adaptive shell for members.
///
/// On tablet: Shows two-pane layout with list and detail
/// On mobile: Shows only the child (list or detail)
class MembersShell extends ConsumerWidget {
  const MembersShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On mobile, just show the child directly
    if (!Breakpoints.isTabletOrLarger(context)) {
      return child;
    }

    // On tablet, use two-pane layout
    return TabletMembersLayout(detailContent: child);
  }
}
