import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/form/form_dialog_scaffold.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/membership.dart';
import '../controllers/memberships_controller.dart';

/// Shows a dialog form for creating or editing a membership plan.
///
/// Returns `true` if the membership was saved successfully.
Future<bool?> showMembershipFormDialog(
  BuildContext context, {
  Membership? membership,
}) {
  return showConstrainedDialog<bool>(
    context: context,
    builder: (context) => MembershipFormDialog(membership: membership),
  );
}

class MembershipFormDialog extends HookConsumerWidget {
  const MembershipFormDialog({super.key, this.membership});

  final Membership? membership;

  bool get isEditing => membership != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);

    final initialValues = isEditing
        ? <String, dynamic>{
            'name': membership!.name,
            'description': membership!.description,
            'durationDays': membership!.durationDays.toString(),
            'price': membership!.price.toString(),
            'isActive': membership!.isActive,
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

      final branchId =
          membership?.branchId ?? ref.read(currentBranchIdProvider) ?? '';

      final membershipData = Membership(
        id: membership?.id ?? '',
        name: values['name'] as String,
        description: values['description'] as String?,
        durationDays:
            int.tryParse(values['durationDays']?.toString() ?? '') ?? 0,
        price: num.tryParse(values['price']?.toString() ?? '') ?? 0,
        branchId: branchId,
        isActive: values['isActive'] as bool? ?? true,
      );

      final controller = ref.read(membershipsControllerProvider.notifier);

      bool success;
      if (isEditing) {
        success = await controller.updateMembership(membershipData);
      } else {
        final created = await controller.createMembership(membershipData);
        success = created != null;
      }

      isSaving.value = false;

      if (success && dialogContext.mounted) {
        showSuccessSnackBar(
          dialogContext,
          message: isEditing
              ? 'Membership plan updated'
              : 'Membership plan created',
          useRootMessenger: false,
        );
        Navigator.of(dialogContext).pop(true);
      } else if (dialogContext.mounted) {
        showErrorSnackBar(
          dialogContext,
          message: isEditing
              ? 'Failed to update membership plan'
              : 'Failed to create membership plan',
          useRootMessenger: false,
        );
      }
    }

    return FormDialogScaffold(
          title: isEditing ? 'Edit Membership Plan' : 'New Membership Plan',
          formKey: formKey,
          dirtyGuard: dirtyGuard,
          isSaving: isSaving.value,
          onSave: handleSave,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FormBuilderTextField(
                name: 'name',
                initialValue: membership?.name,
                decoration:
                    const InputDecoration(labelText: 'Plan Name *'),
                validator: FormBuilderValidators.required(),
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'description',
                initialValue: membership?.description,
                decoration:
                    const InputDecoration(labelText: 'Description'),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'durationDays',
                initialValue: membership?.durationDays.toString() ?? '',
                decoration: const InputDecoration(
                  labelText: 'Duration (days) *',
                  helperText: 'e.g. 30 for monthly, 365 for annual',
                ),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                ]),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),
              FormBuilderTextField(
                name: 'price',
                initialValue: membership?.price.toString() ?? '',
                decoration: const InputDecoration(
                  labelText: 'Price *',
                  prefixText: '\u20B1 ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(),
                  FormBuilderValidators.numeric(),
                ]),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),
              FormBuilderSwitch(
                name: 'isActive',
                initialValue: membership?.isActive ?? true,
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
