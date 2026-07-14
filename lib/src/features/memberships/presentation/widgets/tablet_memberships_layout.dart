import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/state/error_state.dart';
import '../controllers/memberships_controller.dart';
import 'membership_list_panel.dart';

/// Two-pane tablet layout for memberships.
///
/// Left pane: Membership plan list with search
/// Right pane: Membership detail from router or empty state
class TabletMembershipsLayout extends ConsumerWidget {
  const TabletMembershipsLayout({super.key, required this.detailContent});

  final Widget detailContent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipsAsync = ref.watch(membershipsControllerProvider);

    final routerState = GoRouterState.of(context);
    final selectedMembershipId = routerState.pathParameters['id'];

    return membershipsAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorState.fromError(
        error,
        onRetry: () =>
            ref.read(membershipsControllerProvider.notifier).refresh(),
      ),
      data: (memberships) => Row(
        children: [
          SizedBox(
            width: 320,
            child: MembershipListPanel(memberships: memberships),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: selectedMembershipId != null
                ? detailContent
                : const _EmptyMembershipState(),
          ),
        ],
      ),
    );
  }
}

class _EmptyMembershipState extends StatelessWidget {
  const _EmptyMembershipState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.card_membership_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a membership plan to view details',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
