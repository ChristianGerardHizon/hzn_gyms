import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../../core/widgets/form/form_dialog_scaffold.dart';
import '../../../../../core/widgets/form_feedback.dart';
import '../../../domain/user_role.dart';
import '../../controllers/user_roles_controller.dart';
import '../permission_category_widget.dart';

/// Dialog for editing a user role.
class EditRoleDialog extends HookConsumerWidget {
  const EditRoleDialog({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Form key
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: {'name': role.name, 'description': role.description},
    );

    // UI state
    final isSaving = useState(false);

    // Track selected permissions (initialize with existing)
    final selectedPermissions = useState<Set<String>>(
      Set<String>.from(role.permissions),
    );

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

      // Create updated role object
      final updatedRole = UserRole(
        id: role.id,
        name: (values['name'] as String).trim(),
        description: _nullIfEmpty(values['description'] as String?),
        permissions: selectedPermissions.value.toList(),
        isSystem: role.isSystem,
        isDeleted: role.isDeleted,
        created: role.created,
        updated: role.updated,
      );

      final success = await ref
          .read(userRolesControllerProvider.notifier)
          .updateRole(updatedRole);

      if (!success) {
        if (context.mounted) {
          isSaving.value = false;
          showFormErrorDialog(
            context,
            errors: ['Failed to update role. Please try again.'],
          );
        }
        return;
      }

      if (context.mounted) {
        isSaving.value = false;
        context.pop();
        showSuccessSnackBar(context, message: 'Role updated successfully');
      }
    }

    // Check if editing is restricted (system role)
    final isRestricted = role.isSystem;

    return FormDialogScaffold(
      title: 'Edit Role',
      formKey: formKey,
      dirtyGuard: dirtyGuard,
      isSaving: isSaving.value,
      onSave: (_) => handleSave(),
      initialValue: {'name': role.name, 'description': role.description ?? ''},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // System role warning
          if (isRestricted) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This is a system role. Some fields may be restricted.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // === BASIC INFORMATION SECTION ===
          _SectionHeader(
            title: 'Role Information',
            icon: Icons.admin_panel_settings,
          ),
          const SizedBox(height: 16),

          // Name (required)
          FormBuilderTextField(
            name: 'name',
            decoration: const InputDecoration(
              labelText: 'Role Name *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge),
            ),
            enabled: !isSaving.value && !isRestricted,
            textCapitalization: TextCapitalization.words,
            validator: FormBuilderValidators.required(
              errorText: 'Role name is required',
            ),
          ),
          const SizedBox(height: 16),

          // Description
          FormBuilderTextField(
            name: 'description',
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            enabled: !isSaving.value,
            maxLines: 2,
          ),
          const SizedBox(height: 24),

          // === PERMISSIONS SECTION ===
          _SectionHeader(title: 'Permissions', icon: Icons.security),
          const SizedBox(height: 8),

          // Permission count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${selectedPermissions.value.length} permission${selectedPermissions.value.length == 1 ? '' : 's'} selected',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Permission categories
          ...Permissions.allPermissionsByCategory.entries.map((entry) {
            return PermissionCategoryWidget(
              category: entry.key,
              permissions: entry.value,
              selectedPermissions: selectedPermissions.value,
              enabled: !isSaving.value,
              onChanged: (permission, selected) {
                final newSet = Set<String>.from(selectedPermissions.value);
                if (selected) {
                  newSet.add(permission);
                } else {
                  newSet.remove(permission);
                }
                selectedPermissions.value = newSet;
              },
              onSelectAll: (permissions, selectAll) {
                final newSet = Set<String>.from(selectedPermissions.value);
                if (selectAll) {
                  newSet.addAll(permissions);
                } else {
                  newSet.removeAll(permissions);
                }
                selectedPermissions.value = newSet;
              },
            );
          }),
        ],
      ),
    );
  }

  String? _nullIfEmpty(String? text) {
    if (text == null) return null;
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static const _fieldLabels = {
    'name': 'Role Name',
    'description': 'Description',
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

/// Shows the edit role dialog.
void showEditRoleDialog(BuildContext context, UserRole role) {
  showConstrainedDialog(
    context: context,
    builder: (context) => EditRoleDialog(role: role),
  );
}
