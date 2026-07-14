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
import '../../../domain/branch.dart';
import '../../controllers/branches_controller.dart';

/// Dialog for creating or editing a branch.
class BranchFormDialog extends HookConsumerWidget {
  const BranchFormDialog({super.key, this.branch});

  final Branch? branch;

  bool get isEditing => branch != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Form key
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: isEditing
          ? {
              'name': branch!.name,
              'address': branch!.address,
              'contactNumber': branch!.contactNumber,
              'operatingHours': branch!.operatingHours ?? '',
              'cutOffTime': branch!.cutOffTime ?? '',
            }
          : null,
    );

    // UI state
    final isSaving = useState(false);

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

      final branchData = Branch(
        id: branch?.id ?? '',
        name: (values['name'] as String).trim(),
        address: (values['address'] as String).trim(),
        contactNumber: (values['contactNumber'] as String).trim(),
        operatingHours: _nullIfEmpty(values['operatingHours'] as String?),
        cutOffTime: _nullIfEmpty(values['cutOffTime'] as String?),
      );

      bool success;
      if (isEditing) {
        success = await ref
            .read(branchesControllerProvider.notifier)
            .updateBranch(branchData);
      } else {
        success = await ref
            .read(branchesControllerProvider.notifier)
            .createBranch(branchData);
      }

      if (!success) {
        if (context.mounted) {
          isSaving.value = false;
          showFormErrorDialog(
            context,
            errors: ['Failed to save branch. Please try again.'],
          );
        }
        return;
      }

      if (context.mounted) {
        isSaving.value = false;
        context.pop();

        showSuccessSnackBar(
          context,
          message: isEditing
              ? 'Branch updated successfully'
              : 'Branch created successfully',
        );
      }
    }

    return FormDialogScaffold(
      title: isEditing ? 'Edit Branch' : 'New Branch',
      formKey: formKey,
      dirtyGuard: dirtyGuard,
      isSaving: isSaving.value,
      onSave: (_) => handleSave(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Name field
          FormBuilderTextField(
            name: 'name',
            initialValue: branch?.name,
            decoration: const InputDecoration(
              labelText: 'Name *',
              hintText: 'Enter branch name (internal)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.store),
            ),
            enabled: !isSaving.value,
            validator: FormBuilderValidators.required(
              errorText: 'Name is required',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Address field
          FormBuilderTextField(
            name: 'address',
            initialValue: branch?.address,
            decoration: const InputDecoration(
              labelText: 'Address *',
              hintText: 'Enter address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.location_on),
            ),
            enabled: !isSaving.value,
            maxLines: 2,
            validator: FormBuilderValidators.required(
              errorText: 'Address is required',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Contact number field
          FormBuilderTextField(
            name: 'contactNumber',
            initialValue: branch?.contactNumber,
            decoration: const InputDecoration(
              labelText: 'Contact Number *',
              hintText: 'Enter contact number',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.phone),
            ),
            enabled: !isSaving.value,
            keyboardType: TextInputType.phone,
            validator: FormBuilderValidators.required(
              errorText: 'Contact number is required',
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Operating hours field
          FormBuilderTextField(
            name: 'operatingHours',
            initialValue: branch?.operatingHours,
            decoration: const InputDecoration(
              labelText: 'Operating Hours',
              hintText: 'e.g., Mon-Sat 8:00 AM - 5:00 PM',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.schedule),
            ),
            enabled: !isSaving.value,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),

          // Cut-off time field
          FormBuilderTextField(
            name: 'cutOffTime',
            initialValue: branch?.cutOffTime,
            decoration: const InputDecoration(
              labelText: 'Cut-off Time',
              hintText: 'e.g., 4:30 PM',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.timer_off),
            ),
            enabled: !isSaving.value,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }

  static const _fieldLabels = {
    'name': 'Name',
    'address': 'Address',
    'contactNumber': 'Contact Number',
    'operatingHours': 'Operating Hours',
    'cutOffTime': 'Cut-off Time',
  };

  String? _nullIfEmpty(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }
}

/// Shows the branch form dialog.
void showBranchFormDialog(BuildContext context, {Branch? branch}) {
  showConstrainedDialog(
    context: context,
    builder: (context) => BranchFormDialog(branch: branch),
  );
}
