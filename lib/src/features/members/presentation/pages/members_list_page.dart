import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/state/error_state.dart';
import '../controllers/paginated_members_controller.dart';
import '../widgets/member_list_panel.dart';
import '../widgets/member_list_skeleton.dart';

/// Members list page for mobile view.
class MembersListPage extends ConsumerWidget {
  const MembersListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(paginatedMembersControllerProvider);

    return membersAsync.when(
      skipLoadingOnReload: true,
      data: (paginatedState) => MemberListPanel(
        members: paginatedState.items,
        totalCount: paginatedState.totalItems,
        hasMore: paginatedState.hasMore,
        isLoadingMore: paginatedState.isLoadingMore,
      ),
      loading: () => const MemberListSkeleton(),
      error: (error, stack) => ErrorState.fromError(
        error,
        onRetry: () => ref.invalidate(paginatedMembersControllerProvider),
      ),
    );
  }
}
