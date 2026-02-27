import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/paginated_members_controller.dart';
import 'member_list_panel.dart';

/// Two-pane tablet layout for members.
///
/// Left pane: Member list with search, sort, filter
/// Right pane: Member detail from router or empty state
class TabletMembersLayout extends ConsumerWidget {
  const TabletMembersLayout({
    super.key,
    required this.detailContent,
  });

  /// The detail panel content from the router.
  final Widget detailContent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(paginatedMembersControllerProvider);

    // Get selected member ID from current route
    final routerState = GoRouterState.of(context);
    final selectedMemberId = routerState.pathParameters['id'];

    return membersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('Error: ${error.toString()}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref
                  .read(paginatedMembersControllerProvider.notifier)
                  .refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (paginatedState) => Row(
        children: [
          // List panel
          SizedBox(
            width: 320,
            child: MemberListPanel(
              members: paginatedState.items,
              totalCount: paginatedState.totalItems,
              hasMore: paginatedState.hasMore,
              isLoadingMore: paginatedState.isLoadingMore,
            ),
          ),
          const VerticalDivider(width: 1),
          // Detail panel from router
          Expanded(
            child: selectedMemberId != null
                ? detailContent
                : const _EmptyMemberState(),
          ),
        ],
      ),
    );
  }
}

class _EmptyMemberState extends StatelessWidget {
  const _EmptyMemberState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a member to view details',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
