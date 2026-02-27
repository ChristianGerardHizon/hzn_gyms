import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/form/form_dialog_scaffold.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../domain/membership_add_on.dart';
import '../controllers/membership_add_ons_controller.dart';

/// Shows a dialog form for creating or editing a membership add-on.
///
/// Returns `true` if the add-on was saved successfully.
Future<bool?> showMembershipAddOnFormDialog(
  BuildContext context, {
  required String membershipId,
  MembershipAddOn? addOn,
}) {
  return showConstrainedDialog<bool>(
    context: context,
    builder: (context) => MembershipAddOnFormDialog(
      membershipId: membershipId,
      addOn: addOn,
    ),
  );
}

class MembershipAddOnFormDialog extends HookConsumerWidget {
  const MembershipAddOnFormDialog({
    super.key,
    required this.membershipId,
    this.addOn,
  });

  final String membershipId;
  final MembershipAddOn? addOn;

  bool get isEditing => addOn != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);

    final initialValues = isEditing
        ? <String, dynamic>{
            'name': addOn!.name,
            'description': addOn!.description,
            'price': addOn!.price.toString(),
            'isActive': addOn!.isActive,
          }
        : null;

    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: initialValues,
    );

    Future<void> handleSave(BuildContext dialogContext) async {
      if (!formKey.currentState!.saveAndValidate()) return;

      isSaving.value = true;
      final values = formKey.currentState!.value;

      final addOnData = MembershipAddOn(
        id: addOn?.id ?? '',
        membershipId: membershipId,
        name: values['name'] as String,
        description: values['description'] as String?,
        price: num.tryParse(values['price']?.toString() ?? '') ?? 0,
        isActive: values['isActive'] as bool? ?? true,
      );

      final controller = ref.read(
        membershipAddOnsControllerProvider(membershipId).notifier,
      );

      bool success;
      if (isEditing) {
        success = await controller.updateAddOn(addOnData);
      } else {
        final created = await controller.createAddOn(addOnData);
        success = created != null;
      }

      isSaving.value = false;

      if (success && dialogContext.mounted) {
        showSuccessSnackBar(
          dialogContext,
          message: isEditing ? 'Add-on updated' : 'Add-on created',
          useRootMessenger: false,
        );
        Navigator.of(dialogContext).pop(true);
      } else if (dialogContext.mounted) {
        showErrorSnackBar(
          dialogContext,
          message: isEditing
              ? 'Failed to update add-on'
              : 'Failed to create add-on',
          useRootMessenger: false,
        );
      }
    }

    return FormDialogScaffold(
          title: isEditing ? 'Edit Add-On' : 'New Add-On',
          formKey: formKey,
          dirtyGuard: dirtyGuard,
          isSaving: isSaving.value,
          onSave: handleSave,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormBuilderTextField(
                name: 'name',
                initialValue: addOn?.name,
                decoration: const InputDecoration(labelText: 'Name *'),
                validator: FormBuilderValidators.required(),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'description',
                initialValue: addOn?.description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'price',
                initialValue: addOn?.price.toString() ?? '',
                decoration: const InputDecoration(
                  labelText: 'Price *',
                  prefixText: '\u20B1 ',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                ]),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),
              FormBuilderSwitch(
                name: 'isActive',
                initialValue: addOn?.isActive ?? true,
                title: const Text('Active'),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ],
          ),
    );
  }
}
