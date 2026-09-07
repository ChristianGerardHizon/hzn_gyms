import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../../core/routing/routes/users.routes.dart';
import '../../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../../core/widgets/form/form_dialog_scaffold.dart';
import '../../../../../core/widgets/form_feedback.dart';
import '../../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../../../settings/presentation/controllers/branches_controller.dart';
import '../../../domain/user.dart';
import '../../controllers/paginated_users_controller.dart';
import '../../controllers/user_entity_cache.dart';
import '../../controllers/user_roles_controller.dart';

/// Dialog for creating a new user.
class CreateUserDialog extends HookConsumerWidget {
  const CreateUserDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Form key
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(formKey: formKey);

    // UI state
    final isSaving = useState(false);

    // Watch providers for dropdown data
    final rolesAsync = ref.watch(userRolesControllerProvider);
    final branchesAsync = ref.watch(branchesControllerProvider);

    Future<void> handleSave() async {
      final isValid = formKey.currentState!.saveAndValidate();

      if (!isValid) {
        final errors = formKey.currentState?.errors ?? {};
        final errorMessages = formatFormErrors(errors, _fieldLabels);

        if (errorMessages.isNotEmpty) {
          showFormErrorDialog(context, errors: errorMessages);
        }
        return;
      }

      final values = formKey.currentState!.value;

      final orgId = ref.read(currentOrganizationIdProvider);
      if (!hasCreateUserOrganizationId(orgId)) {
        if (context.mounted) {
          showFormErrorDialog(
            context,
            errors: [
              'No organization selected. Switch to an organization before '
                  'creating a user.',
            ],
          );
        }
        return;
      }

      isSaving.value = true;

      final defaultBranchId = values['branch'] as String?;
      final allowedRaw = values['allowedBranches'];
      var allowedBranchIds = allowedRaw is List
          ? allowedRaw.map((e) => e.toString()).toList()
          : <String>[];
      if (defaultBranchId != null &&
          defaultBranchId.isNotEmpty &&
          !allowedBranchIds.contains(defaultBranchId)) {
        allowedBranchIds = [...allowedBranchIds, defaultBranchId];
      }

      final user = User(
        id: '',
        name: (values['name'] as String).trim(),
        email: (values['email'] as String).trim(),
        roleId: values['role'] as String?,
        branchId: defaultBranchId,
        organizationId: orgId,
        allowedBranchIds: allowedBranchIds,
      );

      final password = values['password'] as String;

      final createdUser = await ref
          .read(paginatedUsersControllerProvider.notifier)
          .createUser(user, password);

      if (createdUser == null) {
        if (context.mounted) {
          isSaving.value = false;
          showFormErrorDialog(
            context,
            errors: ['Failed to create user. Please try again.'],
          );
        }
        return;
      }

      if (context.mounted) {
        isSaving.value = false;

        // Root-navigator dialogs sit outside RouteBase.builder, so
        // GoRouterState.of(context) throws. Read path from GoRouter instead
        // and navigate via the router after the dialog is closed.
        final router = GoRouter.of(context);
        final detailLocation = userDetailLocationForCurrentPath(
          router.state.uri.path,
          createdUser.id,
        );

        // Pre-cache the user before navigation to avoid race condition
        ref.read(userEntityCacheProvider.notifier).cacheUser(createdUser);
        showSuccessSnackBar(context, message: 'User created successfully');
        context.pop();
        router.go(detailLocation);
      }
    }

    return FormDialogScaffold(
      title: 'Create User',
      formKey: formKey,
      dirtyGuard: dirtyGuard,
      isSaving: isSaving.value,
      onSave: (_) => handleSave(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // === BASIC INFORMATION SECTION ===
          _SectionHeader(title: 'Basic Information', icon: Icons.person),
          const SizedBox(height: 16),

          // Name (required)
          FormBuilderTextField(
            name: 'name',
            decoration: const InputDecoration(
              labelText: 'Name *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            enabled: !isSaving.value,
            textCapitalization: TextCapitalization.words,
            validator: FormBuilderValidators.required(
              errorText: 'Name is required',
            ),
          ),
          const SizedBox(height: 16),

          // Email (required for login)
          FormBuilderTextField(
            name: 'email',
            decoration: const InputDecoration(
              labelText: 'Email *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            enabled: !isSaving.value,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Email is required'),
              FormBuilderValidators.email(errorText: 'Enter a valid email'),
            ]),
          ),
          const SizedBox(height: 16),

          // Password (required for create)
          FormBuilderTextField(
            name: 'password',
            decoration: const InputDecoration(
              labelText: 'Password *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock),
            ),
            enabled: !isSaving.value,
            obscureText: true,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Password is required'),
              FormBuilderValidators.minLength(
                8,
                errorText: 'Password must be at least 8 characters',
              ),
            ]),
          ),
          const SizedBox(height: 16),

          // Confirm Password
          FormBuilderTextField(
            name: 'confirmPassword',
            decoration: const InputDecoration(
              labelText: 'Confirm Password *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_outline),
            ),
            enabled: !isSaving.value,
            obscureText: true,
            validator: (value) {
              final password =
                  formKey.currentState?.fields['password']?.value as String?;
              if (value == null || value.isEmpty) {
                return 'Please confirm password';
              }
              if (value != password) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          // === ASSIGNMENT SECTION ===
          _SectionHeader(title: 'Assignment', icon: Icons.assignment_ind),
          const SizedBox(height: 16),

          // Role dropdown
          rolesAsync.when(
            data: (roles) => FormBuilderDropdown<String>(
              name: 'role',
              decoration: const InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.admin_panel_settings),
              ),
              enabled: !isSaving.value,
              items: roles.map((role) {
                return DropdownMenuItem(
                  value: role.id,
                  child: Row(
                    children: [
                      Text(role.name),
                      if (role.isSystem) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.tertiaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'System',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
            loading: () => const TextField(
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.admin_panel_settings),
                suffixIcon: SizedBox(
                  width: 20,
                  height: 20,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              enabled: false,
            ),
            error: (_, __) => const TextField(
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.admin_panel_settings),
                errorText: 'Failed to load roles',
              ),
              enabled: false,
            ),
          ),
          const SizedBox(height: 16),

          // Default branch dropdown
          branchesAsync.when(
            data: (branches) => FormBuilderDropdown<String>(
              name: 'branch',
              decoration: const InputDecoration(
                labelText: 'Default Branch',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
                helperText: 'Home branch used when creating records',
              ),
              enabled: !isSaving.value,
              items: branches.map((branch) {
                return DropdownMenuItem(
                  value: branch.id,
                  child: Text(branch.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                final current =
                    formKey.currentState?.fields['allowedBranches']?.value
                        as List<String>?;
                final next = {...?current, value}.toList();
                formKey.currentState?.fields['allowedBranches']?.didChange(
                  next,
                );
              },
            ),
            loading: () => const TextField(
              decoration: InputDecoration(
                labelText: 'Default Branch',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
                suffixIcon: SizedBox(
                  width: 20,
                  height: 20,
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              enabled: false,
            ),
            error: (_, __) => const TextField(
              decoration: InputDecoration(
                labelText: 'Default Branch',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
                errorText: 'Failed to load branches',
              ),
              enabled: false,
            ),
          ),
          const SizedBox(height: 16),

          // Allowed branches multi-select
          branchesAsync.when(
            data: (branches) => FormBuilderCheckboxGroup<String>(
              name: 'allowedBranches',
              decoration: const InputDecoration(
                labelText: 'Allowed Branches',
                border: OutlineInputBorder(),
                helperText: 'Branches this user can switch to',
              ),
              enabled: !isSaving.value,
              orientation: OptionsOrientation.vertical,
              options: branches
                  .map(
                    (branch) => FormBuilderFieldOption(
                      value: branch.id,
                      child: Text(branch.name),
                    ),
                  )
                  .toList(),
              validator: (value) {
                final defaultId =
                    formKey.currentState?.fields['branch']?.value as String?;
                if (defaultId != null &&
                    defaultId.isNotEmpty &&
                    (value == null || !value.contains(defaultId))) {
                  return 'Must include the default branch';
                }
                return null;
              },
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  static const _fieldLabels = {
    'name': 'Name',
    'email': 'Email',
    'password': 'Password',
    'confirmPassword': 'Confirm Password',
    'role': 'Role',
    'branch': 'Default Branch',
    'allowedBranches': 'Allowed Branches',
  };
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

/// Whether [orgId] is present for linking a newly created user.
bool hasCreateUserOrganizationId(String? orgId) =>
    orgId != null && orgId.isNotEmpty;

/// Resolves the user detail location for the shell that opened create-user.
String userDetailLocationForCurrentPath(String currentPath, String userId) {
  return UserDetailRoute(id: userId).location;
}

/// Shows the create user dialog.
void showCreateUserDialog(BuildContext context) {
  showConstrainedDialog(
    context: context,
    builder: (context) => const CreateUserDialog(),
  );
}
