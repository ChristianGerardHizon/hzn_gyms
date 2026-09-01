import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/routes/memberships.routes.dart';
import '../../../../core/utils/currency_format.dart';
import '../../../settings/presentation/controllers/branches_controller.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/membership.dart';
import '../controllers/memberships_controller.dart';
import 'membership_form_dialog.dart';
import 'membership_valid_branches_chips.dart';

/// List panel for displaying membership plans with search and create.
class MembershipListPanel extends HookConsumerWidget {
  const MembershipListPanel({super.key, required this.memberships});

  final List<Membership> memberships;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    useEffect(() {
      void listener() {
        searchQuery.value = searchController.text;
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    final filteredMemberships = searchQuery.value.isEmpty
        ? List<Membership>.from(memberships)
        : memberships.where((m) {
            final query = searchQuery.value.toLowerCase();
            return m.name.toLowerCase().contains(query) ||
                (m.description?.toLowerCase().contains(query) ?? false);
          }).toList();
    filteredMemberships.sort(Membership.compareForList);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memberships'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(membershipsControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search membership plans...',
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),

          // Memberships list
          Expanded(
            child: filteredMemberships.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.card_membership_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          searchQuery.value.isEmpty
                              ? 'No membership plans yet'
                              : 'No plans match "${searchQuery.value}"',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => ref
                        .read(membershipsControllerProvider.notifier)
                        .refresh(),
                    child: ListView.builder(
                      itemCount: filteredMemberships.length,
                      itemBuilder: (context, index) {
                        final membership = filteredMemberships[index];
                        return _MembershipListTile(membership: membership);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSheet(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) async {
    final result = await showMembershipFormDialog(context);
    if (result == true) {
      ref.read(membershipsControllerProvider.notifier).refresh();
    }
  }
}

class _MembershipListTile extends ConsumerWidget {
  const _MembershipListTile({required this.membership});

  final Membership membership;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final branchesAsync = ref.watch(branchesControllerProvider);
    final writeBranchId = ref.watch(effectiveBranchIdForWriteProvider);
    final branchCodeById = <String, String>{
      for (final branch in branchesAsync.value ?? const [])
        branch.id: branch.pillLabel,
    };
    final branchNamesById = <String, String>{
      for (final branch in branchesAsync.value ?? const [])
        branch.id: branch.name,
    };
    final branchColorById = <String, String>{
      for (final branch in branchesAsync.value ?? const [])
        if (branch.color != null && branch.color!.trim().isNotEmpty)
          branch.id: branch.color!,
    };

    Future<void> toggleFavorite() async {
      final updated = membership.copyWith(isFavorite: !membership.isFavorite);
      final success = await ref
          .read(membershipsControllerProvider.notifier)
          .updateMembership(updated);
      if (!success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update favorite')),
        );
      }
    }

    return ListTile(
      isThreeLine: true,
      leading: CircleAvatar(
        backgroundColor: membership.isActive
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          membership.memberNotRequired
              ? Icons.directions_walk
              : Icons.card_membership,
          color: membership.isActive
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(membership.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              membership.durationDisplay,
              membership.price.toCurrency(),
              if (membership.walkInBadgeLabel != null)
                membership.walkInBadgeLabel!,
              if (!membership.isActive) 'Inactive',
            ].join(' · '),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          MembershipValidBranchesChips(
            membership: membership,
            branchCodeById: branchCodeById,
            branchNameById: branchNamesById,
            branchColorById: branchColorById,
            currentBranchId: writeBranchId,
          ),
        ],
      ),
      trailing: IconButton(
        icon: Icon(
          membership.isFavorite ? Icons.star : Icons.star_border,
          color: membership.isFavorite
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant,
        ),
        tooltip: membership.isFavorite
            ? 'Remove from favorites'
            : 'Add to favorites',
        onPressed: toggleFavorite,
      ),
      onTap: () => MembershipDetailRoute(id: membership.id).go(context),
    );
  }
}
