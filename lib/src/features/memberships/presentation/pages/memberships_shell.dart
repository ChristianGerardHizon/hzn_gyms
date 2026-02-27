import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/breakpoints.dart';
import '../widgets/tablet_memberships_layout.dart';

/// Adaptive shell for memberships.
///
/// On tablet: Shows two-pane layout with list and detail
/// On mobile: Shows only the child (list or detail)
class MembershipsShell extends ConsumerWidget {
  const MembershipsShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!Breakpoints.isTabletOrLarger(context)) {
      return child;
    }

    return TabletMembershipsLayout(detailContent: child);
  }
}
