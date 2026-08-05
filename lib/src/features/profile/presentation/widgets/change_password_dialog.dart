import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/form/form_dialog_scaffold.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../users/data/repositories/user_repository.dart';

/// Self-service dialog to change the signed-in user's password.
class ChangePasswordDialog extends HookConsumerWidget {
  const ChangePasswordDialog({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(formKey: formKey);
    final isSaving = useState(false);
    final obscureCurrent = useState(true);
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
      final oldPassword = values['currentPassword'] as String;
      final newPassword = values['password'] as String;
      isSaving.value = true;

      final result = await ref.read(userRepositoryProvider).changePassword(
            userId: userId,
            oldPassword: oldPassword,
            newPassword: newPassword,
          );

      if (!dialogContext.mounted) return;
      isSaving.value = false;

      result.fold(
        (failure) {
          showFormErrorDialog(
            dialogContext,
            errors: [failure.messageString],
          );
        },
        (_) {
          dialogContext.pop();
          showSuccessSnackBar(context, message: 'Password changed');
        },
      );
    }

    return FormDialogScaffold(
      title: 'Change Password',
      formKey: formKey,
      dirtyGuard: dirtyGuard,
      isSaving: isSaving.value,
      saveLabel: 'Change',
      onSave: handleSave,
      maxWidth: DialogConstraints.compactMaxWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter your current password and choose a new one.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          FormBuilderTextField(
            name: 'currentPassword',
            decoration: InputDecoration(
              labelText: 'Current Password *',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  obscureCurrent.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: () => obscureCurrent.value = !obscureCurrent.value,
              ),
            ),
            enabled: !isSaving.value,
            obscureText: obscureCurrent.value,
            autofocus: true,
            validator: FormBuilderValidators.required(
              errorText: 'Current password is required',
            ),
          ),
          const SizedBox(height: 16),
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
  'currentPassword': 'Current Password',
  'password': 'New Password',
  'confirmPassword': 'Confirm Password',
};

/// Shows the change password dialog for the signed-in user.
void showChangePasswordDialog(BuildContext context, {required String userId}) {
  showConstrainedDialog(
    context: context,
    maxWidth: DialogConstraints.compactMaxWidth,
    builder: (context) => ChangePasswordDialog(userId: userId),
  );
}
