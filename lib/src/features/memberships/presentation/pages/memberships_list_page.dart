import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/state/error_state.dart';
import '../controllers/memberships_controller.dart';
import '../widgets/membership_list_panel.dart';

/// Memberships list page for mobile view.
class MembershipsListPage extends ConsumerWidget {
  const MembershipsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipsAsync = ref.watch(membershipsControllerProvider);

    return membershipsAsync.when(
      skipLoadingOnReload: true,
      data: (memberships) => MembershipListPanel(memberships: memberships),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorState.fromError(
        error,
        onRetry: () => ref.invalidate(membershipsControllerProvider),
      ),
    );
  }
}
