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
import '../../../domain/user.dart';
import '../../controllers/paginated_users_controller.dart';

/// Dialog for resetting a user's password (admin action).
class ResetPasswordDialog extends HookConsumerWidget {
  const ResetPasswordDialog({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(formKey: formKey);
    final isSaving = useState(false);
    final obscurePassword = useState(true);
    final obscureConfirm = useState(true);

    Future<void> handleSave(BuildContext dialogContext) async {
      final isValid = formKey.currentState!.saveAndValidate();

      if (!isValid) {
        final errors = formKey.currentState?.errors ?? {};
        final errorMessages = formatFormErrors(errors, _fieldLabels);

        if (errorMessages.isNotEmpty) {
          showFormErrorDialog(dialogContext, errors: errorMessages);
        }
        return;
      }

      final values = formKey.currentState!.value;
      final password = values['password'] as String;
      isSaving.value = true;

      final error = await ref
          .read(paginatedUsersControllerProvider.notifier)
          .resetPassword(user.id, password);

      if (!dialogContext.mounted) return;

      isSaving.value = false;

      if (error != null) {
        showFormErrorDialog(dialogContext, errors: [error]);
        return;
      }

      dialogContext.pop();
      showSuccessSnackBar(
        context,
        message: 'Password reset successfully for ${user.name}',
      );
    }

    return FormDialogScaffold(
      title: 'Reset Password',
      formKey: formKey,
      dirtyGuard: dirtyGuard,
      isSaving: isSaving.value,
      saveLabel: 'Reset',
      onSave: handleSave,
      maxWidth: DialogConstraints.compactMaxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Set a new password for ${user.name} (@${user.username}).',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FormBuilderTextField(
            name: 'password',
            decoration: InputDecoration(
              labelText: 'New Password *',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  obscurePassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => obscurePassword.value = !obscurePassword.value,
              ),
            ),
            enabled: !isSaving.value,
            obscureText: obscurePassword.value,
            autofocus: true,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Password is required'),
              FormBuilderValidators.minLength(
                8,
                errorText: 'Password must be at least 8 characters',
              ),
            ]),
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'confirmPassword',
            decoration: InputDecoration(
              labelText: 'Confirm Password *',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureConfirm.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => obscureConfirm.value = !obscureConfirm.value,
              ),
            ),
            enabled: !isSaving.value,
            obscureText: obscureConfirm.value,
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
        ],
      ),
    );
  }
}

const _fieldLabels = {
  'password': 'New Password',
  'confirmPassword': 'Confirm Password',
};

/// Shows the reset password dialog.
void showResetPasswordDialog(BuildContext context, User user) {
  showConstrainedDialog(
    context: context,
    maxWidth: DialogConstraints.compactMaxWidth,
    builder: (context) => ResetPasswordDialog(user: user),
  );
}
