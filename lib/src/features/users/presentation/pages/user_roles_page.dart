import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/routes/roles.routes.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../domain/user_role.dart';
import '../controllers/user_roles_controller.dart';
import '../widgets/empty_role_detail_state.dart';
import '../widgets/dialogs/edit_role_dialog.dart';
import '../widgets/user_role_detail_panel.dart';
import '../widgets/user_role_list_panel.dart';

/// User roles management page.
///
/// Uses a two-pane layout on tablet and a single list on mobile.
class UserRolesPage extends HookConsumerWidget {
  const UserRolesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rolesAsync = ref.watch(userRolesControllerProvider);
    final isTablet = Breakpoints.isTabletOrLarger(context);

    return rolesAsync.when(
      skipLoadingOnReload: true,
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        body: ErrorState.fromError(
          error,
          onRetry: () =>
              ref.read(userRolesControllerProvider.notifier).refresh(),
        ),
      ),
      data: (roles) {
        final selectedRoleId = useState<String?>(null);

        useEffect(() {
          if (selectedRoleId.value != null &&
              !roles.any((role) => role.id == selectedRoleId.value)) {
            selectedRoleId.value = null;
          }
          return null;
        }, [roles]);

        final selectedRole = selectedRoleId.value == null
            ? null
            : roles.cast<UserRole?>().firstWhere(
                (role) => role?.id == selectedRoleId.value,
                orElse: () => null,
              );

        final listPanel = UserRoleListPanel(
          roles: roles,
          selectedId: selectedRoleId.value,
          onRefresh: () =>
              ref.read(userRolesControllerProvider.notifier).refresh(),
          onEdit: (role) => showEditRoleDialog(context, role),
          onDelete: (role) => _showDeleteConfirmation(context, ref, role),
          onRoleTap: isTablet
              ? (role) => selectedRoleId.value = role.id
              : (role) => RoleDetailRoute(id: role.id).push(context),
        );

        if (!isTablet) {
          return Scaffold(
            appBar: AppBar(title: Text(Translations.of(context).navigation.roles)),
            body: listPanel,
          );
        }

        return Row(
          children: [
            SizedBox(width: 320, child: listPanel),
            const VerticalDivider(width: 1),
            Expanded(
              child: selectedRole != null
                  ? UserRoleDetailPanel(role: selectedRole)
                  : const EmptyRoleDetailState(),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    UserRole role,
  ) {
    if (role.isSystem) {
      showErrorSnackBar(context, message: 'System roles cannot be deleted');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: Text(
          'Are you sure you want to delete the "${role.name}" role?',
        ),
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
