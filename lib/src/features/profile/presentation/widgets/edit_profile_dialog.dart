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
import '../../../users/domain/user.dart';
import '../../../users/presentation/controllers/user_provider.dart';

/// Self-edit dialog: name and username only (no role/branch).
class EditProfileDialog extends HookConsumerWidget {
  const EditProfileDialog({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: {
        'name': user.name,
        'username': user.username,
      },
    );
    final isSaving = useState(false);

    Future<void> handleSave() async {
      final isValid = formKey.currentState!.saveAndValidate();
      if (!isValid) {
        final errors = formKey.currentState?.errors ?? {};
        final errorMessages = formatFormErrors(errors, {
          'name': 'Name',
          'username': 'Username',
        });
        if (errorMessages.isNotEmpty) {
          showFormErrorDialog(context, errors: errorMessages);
        }
        return;
      }

      final values = formKey.currentState!.value;
      isSaving.value = true;

      final result = await ref.read(userRepositoryProvider).updateProfile(
            id: user.id,
            name: (values['name'] as String).trim(),
            username: (values['username'] as String).trim().toLowerCase(),
          );

      if (!context.mounted) return;
      isSaving.value = false;

      result.fold(
        (failure) {
          showFormErrorDialog(
            context,
            errors: [failure.messageString],
          );
        },
        (_) {
          context.pop();
          showSuccessSnackBar(context, message: 'Profile updated');
          ref.invalidate(userProvider(user.id));
        },
      );
    }

    return FormDialogScaffold(
      title: 'Edit Profile',
      formKey: formKey,
      dirtyGuard: dirtyGuard,
      isSaving: isSaving.value,
      onSave: (_) => handleSave(),
      maxWidth: DialogConstraints.compactMaxWidth,
      initialValue: {
        'name': user.name,
        'username': user.username,
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          FormBuilderTextField(
            name: 'username',
            decoration: const InputDecoration(
              labelText: 'Username *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.alternate_email),
            ),
            enabled: !isSaving.value,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Username is required'),
              FormBuilderValidators.minLength(
                3,
                errorText: 'Username must be at least 3 characters',
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

void showEditProfileDialog(BuildContext context, {required User user}) {
  showConstrainedDialog(
    context: context,
    maxWidth: DialogConstraints.compactMaxWidth,
    builder: (context) => EditProfileDialog(user: user),
  );
}
