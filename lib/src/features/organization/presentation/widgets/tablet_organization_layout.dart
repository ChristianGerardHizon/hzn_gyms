import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../../../core/routing/routes/organization.routes.dart';
import '../../../settings/domain/branch.dart';
import '../../../settings/presentation/controllers/branches_controller.dart';
import '../../../settings/presentation/widgets/dialogs/branch_form_dialog.dart';
import '../../../users/presentation/controllers/paginated_users_controller.dart';
import '../../../users/presentation/controllers/user_roles_controller.dart';
import '../../../users/presentation/widgets/dialogs/create_user_dialog.dart';
import '../../../users/presentation/widgets/dialogs/edit_role_dialog.dart';
import '../../../users/presentation/widgets/user_list_panel.dart';
import '../../../users/presentation/widgets/user_role_list_panel.dart';
import 'empty_organization_state.dart';
import 'organization_nav_panel.dart';

/// Three-panel tablet layout for organization management.
///
/// Panel 1 (72px): Navigation rail for Users/Roles/Branches mode selection
/// Panel 2 (320px): List panel (users, roles, or branches based on current mode)
/// Panel 3 (expanded): Detail panel from router or empty state
class TabletOrganizationLayout extends ConsumerWidget {
  const TabletOrganizationLayout({
    super.key,
    required this.detailChild,
  });

  /// The detail panel content from the router.
  final Widget detailChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerState = GoRouterState.of(context);
    final path = routerState.uri.path;
    final selectedId = routerState.pathParameters['id'];

    // Determine current mode from path
    final OrganizationMode currentMode;
    if (path.contains('/roles')) {
      currentMode = OrganizationMode.roles;
    } else if (path.contains('/branches')) {
      currentMode = OrganizationMode.branches;
    } else {
      currentMode = OrganizationMode.users;
    }

    return Row(
      children: [
        // Panel 1: Navigation
        OrganizationNavPanel(
          currentMode: currentMode,
          onModeChanged: (mode) {
            switch (mode) {
              case OrganizationMode.users:
                const OrganizationUsersRoute().go(context);
              case OrganizationMode.roles:
                const OrganizationRolesRoute().go(context);
              case OrganizationMode.branches:
                const OrganizationBranchesRoute().go(context);
            }
          },
        ),
        const VerticalDivider(width: 1),

        // Panel 2: List
        SizedBox(
          width: 320,
          child: switch (currentMode) {
            OrganizationMode.users => _UsersListWrapper(selectedId: selectedId),
            OrganizationMode.roles => _RolesListWrapper(selectedId: selectedId),
            OrganizationMode.branches =>
              _BranchesListWrapper(selectedId: selectedId),
          },
        ),
        const VerticalDivider(width: 1),

        // Panel 3: Detail
        Expanded(
          child: selectedId != null
              ? detailChild
              : EmptyOrganizationState(mode: currentMode),
        ),
      ],
    );
  }
}

/// Wrapper for UserListPanel with organization-specific navigation.
class _UsersListWrapper extends ConsumerWidget {
  const _UsersListWrapper({required this.selectedId});

  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(paginatedUsersControllerProvider);
    final usersController = ref.read(paginatedUsersControllerProvider.notifier);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'org_users_fab',
        onPressed: () => showCreateUserDialog(context),
        tooltip: 'Add User',
        child: const Icon(Icons.add),
      ),
      body: usersAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState.fromError(
          error,
          compact: true,
          onRetry: () => usersController.refresh(),
        ),
        data: (paginatedState) => UserListPanel(
          paginatedState: paginatedState,
          selectedId: selectedId,
          onUserTap: (user) {
            OrganizationUserDetailRoute(id: user.id).go(context);
          },
          onRefresh: () => usersController.refresh(),
          onLoadMore: () => usersController.loadMore(),
        ),
      ),
    );
  }
}

/// Wrapper for UserRoleListPanel with organization-specific navigation.
class _RolesListWrapper extends ConsumerWidget {
  const _RolesListWrapper({required this.selectedId});

  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(userRolesControllerProvider);
    final rolesController = ref.read(userRolesControllerProvider.notifier);

    return rolesAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorState.fromError(
        error,
        compact: true,
        onRetry: () => rolesController.refresh(),
      ),
      data: (roles) => UserRoleListPanel(
        roles: roles,
        selectedId: selectedId,
        onRefresh: () => rolesController.refresh(),
        onEdit: (role) => showEditRoleDialog(context, role),
        onDelete: (role) => _confirmDeleteRole(context, ref, role),
        onRoleTap: (role) {
          OrganizationRoleDetailRoute(id: role.id).go(context);
        },
      ),
    );
  }

  void _confirmDeleteRole(BuildContext context, WidgetRef ref, role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Role'),
        content:
            Text('Are you sure you want to delete the "${role.name}" role?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(userRolesControllerProvider.notifier)
                  .deleteRole(role.id);
              if (context.mounted) {
                if (success) {
                  showSuccessSnackBar(context, message: 'Role deleted');
                } else {
                  showErrorSnackBar(context, message: 'Failed to delete role');
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

/// Wrapper for BranchListPanel with organization-specific navigation.
class _BranchesListWrapper extends HookConsumerWidget {
  const _BranchesListWrapper({required this.selectedId});

  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);
    final branchesAsync = ref.watch(branchesControllerProvider);
    final controller = ref.read(branchesControllerProvider.notifier);

    // Search state
    final searchController = useTextEditingController();
    final searchText = useState('');

    final query = searchText.value.trim();
    final isSearchActive = query.isNotEmpty;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'branch_fab',
        onPressed: () => showBranchFormDialog(context),
        tooltip: 'Add Branch',
        child: const Icon(Icons.add),
      ),
      body: branchesAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState.fromError(
          error,
          compact: true,
          onRetry: () => controller.refresh(),
        ),
        data: (branches) {
          final filteredBranches = isSearchActive
              ? _filterBranches(branches, query)
              : branches;
          final totalCount = filteredBranches.length;

          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Row(
                  children: [
                    Text('Branches', style: theme.textTheme.titleLarge),
                    const Spacer(),
                    Text(
                      '$totalCount total',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // Search
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _BranchSearchInput(
                  controller: searchController,
                  onTextChanged: (text) => searchText.value = text,
                  searchText: searchText.value,
                  hintText: '${t.common.search}...',
                ),
              ),

              // List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.refresh(),
                  child: filteredBranches.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 80),
                            Icon(
                              Icons.store_outlined,
                              size: 80,
                              color: theme.colorScheme.outlineVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isSearchActive
                                  ? 'No branches match "$query"'
                                  : 'No branches yet',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isSearchActive
                                  ? 'Try a different search term'
                                  : 'Tap + to add a branch',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: filteredBranches.length,
                          itemBuilder: (context, index) {
                            final branch = filteredBranches[index];
                            final isSelected = branch.id == selectedId;

                            return _BranchListTile(
                              branch: branch,
                              isSelected: isSelected,
                              onTap: () =>
                                  OrganizationBranchDetailRoute(id: branch.id)
                                      .go(context),
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BranchListTile extends StatelessWidget {
  const _BranchListTile({
    required this.branch,
    required this.isSelected,
    required this.onTap,
  });

  final Branch branch;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(
        alpha: 0.3,
      ),
      leading: CircleAvatar(
        backgroundColor: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.primaryContainer,
        child: Icon(
          Icons.store_outlined,
          color: isSelected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(branch.name),
      subtitle: Text(
        branch.address,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _BranchSearchInput extends StatelessWidget {
  const _BranchSearchInput({
    required this.controller,
    required this.onTextChanged,
    required this.searchText,
    required this.hintText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onTextChanged;
  final String searchText;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onTextChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchText.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        onTextChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }
}

List<Branch> _filterBranches(List<Branch> branches, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return branches;
  }

  return branches.where((b) {
    final nameMatch = b.name.toLowerCase().contains(normalizedQuery);
    final addressMatch = b.address.toLowerCase().contains(normalizedQuery);
    return nameMatch || addressMatch;
  }).toList();
}
