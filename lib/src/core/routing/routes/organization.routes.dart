import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../widgets/form_feedback.dart';
import '../../../features/organization/presentation/pages/organization_shell.dart';
import '../../../features/settings/domain/branch.dart';
import '../../../features/settings/presentation/controllers/branches_controller.dart';
import '../../../features/settings/presentation/widgets/dialogs/branch_form_dialog.dart';
import '../../../features/users/domain/user_tab.dart';
import '../../../features/users/presentation/controllers/paginated_users_controller.dart';
import '../../../features/users/presentation/controllers/user_roles_controller.dart';
import '../../../features/users/presentation/pages/user_detail_page.dart';
import '../../../features/users/presentation/widgets/dialogs/create_user_dialog.dart';
import '../../../features/users/presentation/widgets/dialogs/edit_role_dialog.dart';
import '../../../features/users/presentation/widgets/user_list_panel.dart';
import '../../../features/users/presentation/widgets/user_role_detail_panel.dart';
import '../../../features/users/presentation/widgets/user_role_list_panel.dart';
import '../../i18n/strings.g.dart';
import '../../utils/breakpoints.dart';

part 'organization.routes.g.dart';

/// Organization shell route for 3-panel layout.
///
/// On tablet: Shows nav rail + list + detail side-by-side
/// On mobile: Shows list, then navigates to detail
@TypedShellRoute<OrganizationShellRoute>(
  routes: [
    TypedGoRoute<OrganizationRoute>(
      path: OrganizationRoute.path,
      routes: [
        TypedGoRoute<OrganizationUsersRoute>(
          path: 'users',
          routes: [
            TypedGoRoute<OrganizationUserDetailRoute>(path: ':id'),
          ],
        ),
        TypedGoRoute<OrganizationRolesRoute>(
          path: 'roles',
          routes: [
            TypedGoRoute<OrganizationRoleDetailRoute>(path: ':id'),
          ],
        ),
        TypedGoRoute<OrganizationBranchesRoute>(
          path: 'branches',
          routes: [
            TypedGoRoute<OrganizationBranchDetailRoute>(path: ':id'),
          ],
        ),
      ],
    ),
  ],
)
class OrganizationShellRoute extends ShellRouteData {
  const OrganizationShellRoute();

  @override
  Widget builder(BuildContext context, GoRouterState state, Widget navigator) {
    return OrganizationShell(child: navigator);
  }
}

/// Organization root route.
///
/// On tablet: Redirects to /organization/users (3-panel layout)
/// On mobile: Shows landing page with Users/Roles options
class OrganizationRoute extends GoRouteData with $OrganizationRoute {
  const OrganizationRoute();

  static const path = '/organization';

  @override
  String? redirect(BuildContext context, GoRouterState state) {
    // Only redirect on tablet - mobile shows landing page
    if (Breakpoints.isTabletOrLarger(context) && state.uri.path == path) {
      return '$path/users';
    }
    return null;
  }

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // Mobile: Show landing page with Users/Roles options
    return const _MobileOrganizationLandingPage();
  }
}

/// Organization users list route.
class OrganizationUsersRoute extends GoRouteData with $OrganizationUsersRoute {
  const OrganizationUsersRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // On tablet, handled by shell - return empty
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    // Mobile: Show users list
    return const _OrganizationUsersListPage();
  }
}

/// Organization user detail route.
class OrganizationUserDetailRoute extends GoRouteData
    with $OrganizationUserDetailRoute {
  const OrganizationUserDetailRoute({required this.id, this.tab});

  final String id;
  final String? tab;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    final tabName = state.uri.queryParameters['tab'];
    return UserDetailPage(
      userId: id,
      initialTab: UserTab.fromString(tabName),
    );
  }
}

/// Organization roles list route.
class OrganizationRolesRoute extends GoRouteData with $OrganizationRolesRoute {
  const OrganizationRolesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // On tablet, handled by shell - return empty
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    // Mobile: Show roles list
    return const _OrganizationRolesListPage();
  }
}

/// Organization role detail route.
class OrganizationRoleDetailRoute extends GoRouteData
    with $OrganizationRoleDetailRoute {
  const OrganizationRoleDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _RoleDetailWrapper(roleId: id);
  }
}

/// Organization branches list route.
class OrganizationBranchesRoute extends GoRouteData
    with $OrganizationBranchesRoute {
  const OrganizationBranchesRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    // On tablet, handled by shell - return empty
    if (Breakpoints.isTabletOrLarger(context)) {
      return const SizedBox.shrink();
    }
    // Mobile: Show branches list
    return const _OrganizationBranchesListPage();
  }
}

/// Organization branch detail route.
class OrganizationBranchDetailRoute extends GoRouteData
    with $OrganizationBranchDetailRoute {
  const OrganizationBranchDetailRoute({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return _BranchDetailWrapper(branchId: id);
  }
}

// ============================================================================
// Mobile Pages
// ============================================================================

/// Mobile landing page for organization with Users/Roles/Branches selection.
class _MobileOrganizationLandingPage extends StatelessWidget {
  const _MobileOrganizationLandingPage();

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.navigation.organization),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _OrganizationOptionCard(
            icon: Icons.people,
            title: t.navigation.users,
            color: theme.colorScheme.primary,
            onTap: () => const OrganizationUsersRoute().go(context),
          ),
          const SizedBox(height: 16),
          _OrganizationOptionCard(
            icon: Icons.admin_panel_settings,
            title: t.navigation.roles,
            color: theme.colorScheme.secondary,
            onTap: () => const OrganizationRolesRoute().go(context),
          ),
          const SizedBox(height: 16),
          _OrganizationOptionCard(
            icon: Icons.store,
            title: t.navigation.branches,
            color: theme.colorScheme.tertiary,
            onTap: () => const OrganizationBranchesRoute().go(context),
          ),
        ],
      ),
    );
  }
}

/// Card widget for organization option selection.
class _OrganizationOptionCard extends StatelessWidget {
  const _OrganizationOptionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      size: 40,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Mobile users list page for organization.
class _OrganizationUsersListPage extends ConsumerWidget {
  const _OrganizationUsersListPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginatedAsync = ref.watch(paginatedUsersControllerProvider);
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.navigation.users),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            tooltip: t.navigation.roles,
            onPressed: () => const OrganizationRolesRoute().go(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'org_users_fab',
        onPressed: () => showCreateUserDialog(context),
        tooltip: 'Add User',
        child: const Icon(Icons.add),
      ),
      body: paginatedAsync.when(
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
                    .read(paginatedUsersControllerProvider.notifier)
                    .refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (paginatedState) => UserListPanel(
          paginatedState: paginatedState,
          selectedId: null,
          onUserTap: (user) {
            OrganizationUserDetailRoute(id: user.id).push(context);
          },
          onRefresh: () =>
              ref.read(paginatedUsersControllerProvider.notifier).refresh(),
          onLoadMore: () =>
              ref.read(paginatedUsersControllerProvider.notifier).loadMore(),
        ),
      ),
    );
  }
}

/// Mobile roles list page for organization.
class _OrganizationRolesListPage extends ConsumerWidget {
  const _OrganizationRolesListPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(userRolesControllerProvider);
    final t = Translations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.navigation.roles),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: t.navigation.users,
            onPressed: () => const OrganizationUsersRoute().go(context),
          ),
        ],
      ),
      body: rolesAsync.when(
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
                onPressed: () =>
                    ref.read(userRolesControllerProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (roles) => UserRoleListPanel(
          roles: roles,
          selectedId: null,
          onRefresh: () =>
              ref.read(userRolesControllerProvider.notifier).refresh(),
          onEdit: (role) => showEditRoleDialog(context, role),
          onDelete: (role) => _confirmDeleteRole(context, ref, role),
          onRoleTap: (role) {
            OrganizationRoleDetailRoute(id: role.id).push(context);
          },
        ),
      ),
    );
  }

  void _confirmDeleteRole(BuildContext context, WidgetRef ref, role) {
    if (role.isSystem) {
      showErrorSnackBar(context, message: 'System roles cannot be deleted');
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Role'),
        content:
            Text('Are you sure you want to delete the "${role.name}" role?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
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

/// Wrapper to fetch and display role detail.
class _RoleDetailWrapper extends ConsumerWidget {
  const _RoleDetailWrapper({required this.roleId});

  final String roleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(userRolesControllerProvider);

    return rolesAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
            ],
          ),
        ),
      ),
      data: (roles) {
        final role = roles.cast().firstWhere(
              (r) => r.id == roleId,
              orElse: () => null,
            );

        if (role == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('Role not found'),
            ),
          );
        }

        return UserRoleDetailPanel(role: role);
      },
    );
  }
}

/// Mobile branches list page for organization.
class _OrganizationBranchesListPage extends ConsumerWidget {
  const _OrganizationBranchesListPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branchesAsync = ref.watch(branchesControllerProvider);
    final t = Translations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.navigation.branches),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: t.navigation.users,
            onPressed: () => const OrganizationUsersRoute().go(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'branch_fab',
        onPressed: () => showBranchFormDialog(context),
        tooltip: 'Add Branch',
        child: const Icon(Icons.add),
      ),
      body: branchesAsync.when(
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
                onPressed: () =>
                    ref.read(branchesControllerProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (branches) {
          if (branches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No branches yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a branch',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(branchesControllerProvider.notifier).refresh(),
            child: ListView.builder(
              itemCount: branches.length,
              itemBuilder: (context, index) {
                final branch = branches[index];
                return _MobileBranchListTile(
                  branch: branch,
                  onTap: () => OrganizationBranchDetailRoute(id: branch.id)
                      .push(context),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _MobileBranchListTile extends StatelessWidget {
  const _MobileBranchListTile({
    required this.branch,
    required this.onTap,
  });

  final Branch branch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Icon(
          Icons.store_outlined,
          color: theme.colorScheme.onPrimaryContainer,
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

/// Wrapper to display branch detail with organization navigation.
class _BranchDetailWrapper extends ConsumerWidget {
  const _BranchDetailWrapper({required this.branchId});

  final String branchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final branchesAsync = ref.watch(branchesControllerProvider);

    // Find the branch from the list
    final branches = branchesAsync.value;
    final branch = branches?.cast<Branch?>().firstWhere(
          (b) => b?.id == branchId,
          orElse: () => null,
        );

    if (branchesAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (branch == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'Branch not found',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _OrganizationBranchDetailPage(branch: branch);
  }
}

/// Read-only branch detail page for organization section (mobile).
class _OrganizationBranchDetailPage extends ConsumerWidget {
  const _OrganizationBranchDetailPage({required this.branch});

  final Branch branch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

    return Scaffold(
      appBar: AppBar(
        title: Text(branch.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => showBranchFormDialog(context, branch: branch),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _handleDelete(context, ref),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Branch header card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.store,
                        size: 32,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            branch.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Details section
            Text(
              'Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow(
                      theme,
                      icon: Icons.store,
                      label: 'Name',
                      value: branch.name,
                    ),
                    _buildDetailRow(
                      theme,
                      icon: Icons.location_on,
                      label: 'Address',
                      value: branch.address,
                    ),
                    _buildDetailRow(
                      theme,
                      icon: Icons.phone,
                      label: 'Contact Number',
                      value: branch.contactNumber,
                    ),
                    if (branch.operatingHours != null &&
                        branch.operatingHours!.isNotEmpty)
                      _buildDetailRow(
                        theme,
                        icon: Icons.schedule,
                        label: 'Operating Hours',
                        value: branch.operatingHours!,
                      ),
                    if (branch.cutOffTime != null &&
                        branch.cutOffTime!.isNotEmpty)
                      _buildDetailRow(
                        theme,
                        icon: Icons.timer_off,
                        label: 'Cut-off Time',
                        value: branch.cutOffTime!,
                      ),
                    if (branch.created != null)
                      _buildDetailRow(
                        theme,
                        icon: Icons.calendar_today,
                        label: 'Created',
                        value: dateFormat.format(branch.created!.toLocal()),
                      ),
                    if (branch.updated != null)
                      _buildDetailRow(
                        theme,
                        icon: Icons.update,
                        label: 'Last Updated',
                        value: dateFormat.format(branch.updated!.toLocal()),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Branch'),
        content: Text('Are you sure you want to delete "${branch.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await ref
        .read(branchesControllerProvider.notifier)
        .deleteBranch(branch.id);

    if (context.mounted) {
      if (success) {
        showSuccessSnackBar(context, message: 'Branch deleted successfully');
        context.pop();
      } else {
        showErrorSnackBar(context,
            message: 'Failed to delete branch. Please try again.');
      }
    }
  }
}
