import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/paginated_members_controller.dart';
import '../widgets/member_list_panel.dart';

/// Members list page for mobile view.
class MembersListPage extends ConsumerWidget {
  const MembersListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(paginatedMembersControllerProvider);

    return membersAsync.when(
      data: (paginatedState) => MemberListPanel(
        members: paginatedState.items,
        totalCount: paginatedState.totalItems,
        hasMore: paginatedState.hasMore,
        isLoadingMore: paginatedState.isLoadingMore,
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('Error loading members: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.invalidate(paginatedMembersControllerProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
