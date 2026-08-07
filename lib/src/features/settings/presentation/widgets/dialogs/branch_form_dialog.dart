import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
              'code': branch!.code,
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
        code: (values['code'] as String).trim().toUpperCase(),
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
          FormBuilderTextField(
            name: 'name',
            initialValue: branch?.name,
            decoration: const InputDecoration(
              labelText: 'Name *',
              hintText: 'Enter branch name (e.g. Bacolod Branch)',
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
          FormBuilderTextField(
            name: 'code',
            initialValue: branch?.code,
            decoration: const InputDecoration(
              labelText: 'Code *',
              hintText: 'e.g. BCD, TAL',
              helperText: 'Short label for pills (max 5 letters/numbers)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
              counterText: '',
            ),
            enabled: !isSaving.value,
            maxLength: 5,
            textCapitalization: TextCapitalization.characters,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              _UpperCaseTextFormatter(),
            ],
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'Code is required'),
              FormBuilderValidators.minLength(1, errorText: 'Code is required'),
              FormBuilderValidators.maxLength(
                5,
                errorText: 'Code must be at most 5 characters',
              ),
              FormBuilderValidators.match(
                RegExp(r'^[A-Za-z0-9]+$'),
                errorText: 'Letters and numbers only',
              ),
            ]),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
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
    'code': 'Code',
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

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

/// Shows the branch form dialog.
void showBranchFormDialog(BuildContext context, {Branch? branch}) {
  showConstrainedDialog(
    context: context,
    builder: (context) => BranchFormDialog(branch: branch),
  );
}
