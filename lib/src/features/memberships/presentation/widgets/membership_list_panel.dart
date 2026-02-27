import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/routes/memberships.routes.dart';
import '../../../../core/utils/currency_format.dart';
import '../../domain/membership.dart';
import '../controllers/memberships_controller.dart';
import 'membership_form_dialog.dart';

/// List panel for displaying membership plans with search and create.
class MembershipListPanel extends HookConsumerWidget {
  const MembershipListPanel({
    super.key,
    required this.memberships,
  });

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
        ? memberships
        : memberships.where((m) {
            final query = searchQuery.value.toLowerCase();
            return m.name.toLowerCase().contains(query) ||
                (m.description?.toLowerCase().contains(query) ?? false);
          }).toList();

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
                          color: theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.5),
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

class _MembershipListTile extends StatelessWidget {
  const _MembershipListTile({required this.membership});

  final Membership membership;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: membership.isActive
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        child: Icon(
          Icons.card_membership,
          color: membership.isActive
              ? theme.colorScheme.onPrimaryContainer
              : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(membership.name),
      subtitle: Text(
        '${membership.durationDisplay} - ${membership.price.toCurrency()}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: !membership.isActive
          ? Chip(
              label: Text(
                'Inactive',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            )
          : null,
      onTap: () => MembershipDetailRoute(id: membership.id).go(context),
    );
  }
}
