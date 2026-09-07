import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../users/domain/user.dart';
import '../../../users/presentation/controllers/paginated_users_controller.dart';
import '../controllers/organization_setup_controller.dart';

/// Step 4 — create the org admin user (email login + Admin role).
class OrganizationSetupAdminUserForm extends HookConsumerWidget {
  const OrganizationSetupAdminUserForm({
    super.key,
    required this.organizationId,
    required this.defaultBranchId,
    required this.onCreated,
  });

  final String organizationId;
  final String? defaultBranchId;
  final VoidCallback onCreated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);
    final obscurePassword = useState(true);

    if (defaultBranchId == null || defaultBranchId!.isEmpty) {
      return Text(t.organizations.setupBranchRequiredFirst);
    }

    Future<void> handleSave() async {
      if (!(formKey.currentState?.saveAndValidate() ?? false)) return;
      isSaving.value = true;
      final values = formKey.currentState!.value;
      final adminRole = await ref
          .read(organizationSetupControllerProvider(organizationId).notifier)
          .adminRole();
      if (adminRole == null) {
        isSaving.value = false;
        if (context.mounted) {
          showFormErrorDialog(
            context,
            errors: [t.organizations.setupAdminRoleMissing],
          );
        }
        return;
      }

      final branchId = defaultBranchId!;
      final user = User(
        id: '',
        name: (values['name'] as String).trim(),
        email: (values['email'] as String).trim(),
        roleId: adminRole.id,
        branchId: branchId,
        organizationId: organizationId,
        allowedBranchIds: [branchId],
      );

      final created = await ref
          .read(paginatedUsersControllerProvider.notifier)
          .createUser(user, values['password'] as String);

      isSaving.value = false;
      if (created == null) {
        if (context.mounted) {
          showFormErrorDialog(
            context,
            errors: [t.organizations.setupAdminUserFailed],
          );
        }
        return;
      }
      onCreated();
    }

    return FormBuilder(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormBuilderTextField(
            name: 'name',
            decoration: InputDecoration(
              labelText: '${t.organizations.setupAdminName} *',
              border: const OutlineInputBorder(),
            ),
            validator: FormBuilderValidators.required(),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'email',
            decoration: InputDecoration(
              labelText: '${t.organizations.setupAdminEmail} *',
              border: const OutlineInputBorder(),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.email(),
            ]),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'password',
            obscureText: obscurePassword.value,
            decoration: InputDecoration(
              labelText: '${t.organizations.setupAdminPassword} *',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () => obscurePassword.value = !obscurePassword.value,
              ),
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.minLength(8),
            ]),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: isSaving.value ? null : handleSave,
            child: isSaving.value
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(t.organizations.setupCreateAdminUser),
          ),
        ],
      ),
    );
  }
}
