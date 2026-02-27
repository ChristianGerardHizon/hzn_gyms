import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../../core/i18n/strings.g.dart';
import '../../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../../core/widgets/dialog_close_handler.dart';
import '../../../../../core/widgets/form_feedback.dart';
import '../../../../settings/presentation/controllers/branches_controller.dart';
import '../../../domain/user.dart';
import '../../controllers/paginated_users_controller.dart';
import '../../controllers/user_provider.dart';
import '../../controllers/user_roles_controller.dart';

/// Dialog for editing user information.
class EditUserDialog extends HookConsumerWidget {
  const EditUserDialog({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    // Form key
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: {
        'name': user.name,
        'username': user.username,
        'role': user.roleId,
        'branch': user.branchId,
      },
    );

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
      isSaving.value = true;

      // Create updated user object (preserve existing values not in form)
      final updatedUser = User(
        id: user.id,
        name: (values['name'] as String).trim(),
        username: (values['username'] as String).trim().toLowerCase(),
        avatar: user.avatar,
        verified: user.verified,
        roleId: values['role'] as String?,
        branchId: values['branch'] as String?,
        isDeleted: user.isDeleted,
        created: user.created,
        updated: user.updated,
      );

      final success = await ref
          .read(paginatedUsersControllerProvider.notifier)
          .updateUser(updatedUser);

      if (!success) {
        if (context.mounted) {
          isSaving.value = false;
          showFormErrorDialog(
            context,
            errors: ['Failed to update user. Please try again.'],
          );
        }
        return;
      }

      if (context.mounted) {
        isSaving.value = false;
        context.pop();

        showSuccessSnackBar(context, message: 'User updated successfully');

        // Refresh detail view by invalidating the provider
        ref.invalidate(userProvider(user.id));
      }
    }

    return DialogCloseHandler(
      onClose: (ctx) => dirtyGuard.confirmDiscard(ctx),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: dirtyGuard.onPopInvokedWithResult,
        child: ConstrainedDialogContent(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: isSaving.value
                          ? null
                          : () async {
                              if (await dirtyGuard.confirmDiscard(context)) {
                                if (context.mounted) context.pop();
                              }
                            },
                    ),
                    Expanded(
                      child:
                          Text('Edit User', style: theme.textTheme.titleLarge),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: TextButton(
                      onPressed: isSaving.value
                          ? null
                          : () async {
                              if (await dirtyGuard.confirmDiscard(context)) {
                                if (context.mounted) context.pop();
                              }
                            },
                      child: Text(t.common.cancel),
                    ),
                  ),
                  FilledButton(
                    onPressed: isSaving.value ? null : handleSave,
                    child: isSaving.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(t.common.save),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Content
            Expanded(
              child: FormBuilder(
                key: formKey,
                initialValue: {
                  'name': user.name,
                  'username': user.username,
                  'role': user.roleId,
                  'branch': user.branchId,
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),

                      // === BASIC INFORMATION SECTION ===
                      _SectionHeader(
                        title: 'Basic Information',
                        icon: Icons.person,
                      ),
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

                      // Username (required)
                      FormBuilderTextField(
                        name: 'username',
                        decoration: const InputDecoration(
                          labelText: 'Username *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.alternate_email),
                        ),
                        enabled: !isSaving.value,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(
                            errorText: 'Username is required',
                          ),
                          FormBuilderValidators.minLength(
                            3,
                            errorText: 'Username must be at least 3 characters',
                          ),
                        ]),
                      ),
                      const SizedBox(height: 8),

                      // Password note
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Use "Reset Password" from the user detail page to change the password.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // === ASSIGNMENT SECTION ===
                      _SectionHeader(
                        title: 'Assignment',
                        icon: Icons.assignment_ind,
                      ),
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
                                        color:
                                            theme.colorScheme.tertiaryContainer,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'System',
                                        style:
                                            theme.textTheme.labelSmall?.copyWith(
                                          color: theme
                                              .colorScheme.onTertiaryContainer,
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
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
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

                      // Branch dropdown
                      branchesAsync.when(
                        data: (branches) => FormBuilderDropdown<String>(
                          name: 'branch',
                          decoration: const InputDecoration(
                            labelText: 'Branch',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.business),
                          ),
                          enabled: !isSaving.value,
                          items: branches.map((branch) {
                            return DropdownMenuItem(
                              value: branch.id,
                              child: Text(branch.name),
                            );
                          }).toList(),
                        ),
                        loading: () => const TextField(
                          decoration: InputDecoration(
                            labelText: 'Branch',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.business),
                            suffixIcon: SizedBox(
                              width: 20,
                              height: 20,
                              child: Padding(
                                padding: EdgeInsets.all(12),
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          ),
                          enabled: false,
                        ),
                        error: (_, __) => const TextField(
                          decoration: InputDecoration(
                            labelText: 'Branch',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.business),
                            errorText: 'Failed to load branches',
                          ),
                          enabled: false,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // === STATUS SECTION ===
                      _SectionHeader(
                        title: 'Status',
                        icon: Icons.info_outline,
                      ),
                      const SizedBox(height: 16),

                      // Status info (read-only)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: theme.colorScheme.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _StatusRow(
                              label: 'Account Verified',
                              value: user.verified ? 'Yes' : 'No',
                              icon: user.verified
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              iconColor: user.verified
                                  ? Colors.green
                                  : theme.colorScheme.error,
                            ),
                            const SizedBox(height: 8),
                            if (user.created != null)
                              _StatusRow(
                                label: 'Created',
                                value: _formatDate(user.created!),
                                icon: Icons.calendar_today,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static const _fieldLabels = {
    'name': 'Name',
    'username': 'Username',
    'role': 'Role',
    'branch': 'Branch',
  };
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
  });

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

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: iconColor ?? theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Shows the edit user dialog.
void showEditUserDialog(BuildContext context, User user) {
  showConstrainedDialog(
    context: context,
    builder: (context) => EditUserDialog(user: user),
  );
}
