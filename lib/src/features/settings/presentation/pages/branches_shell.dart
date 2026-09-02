import 'package:flutter/material.dart';

import '../../../../core/utils/breakpoints.dart';
import '../widgets/tablet_branches_layout.dart';

/// Adaptive shell for branches list/detail layout.
class BranchesShell extends StatelessWidget {
  const BranchesShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!Breakpoints.isTabletOrLarger(context)) {
      return child;
    }

    return TabletBranchesLayout(detailChild: child);
  }
}
