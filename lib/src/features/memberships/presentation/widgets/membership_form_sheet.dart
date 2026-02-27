import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/membership.dart';
import '../controllers/memberships_controller.dart';

/// Shows a bottom sheet form for creating or editing a membership plan.
///
/// Returns `true` if the membership was saved successfully.
Future<bool?> showMembershipFormSheet(
  BuildContext context, {
  Membership? membership,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _MembershipFormSheet(membership: membership),
  );
}

class _MembershipFormSheet extends HookConsumerWidget {
  const _MembershipFormSheet({this.membership});

  final Membership? membership;

  bool get isEditing => membership != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);

    Future<void> handleSave() async {
      if (!formKey.currentState!.saveAndValidate()) return;

      isSaving.value = true;
      final values = formKey.currentState!.value;

      final branchId =
          membership?.branchId ?? ref.read(currentBranchIdProvider) ?? '';

      final membershipData = Membership(
        id: membership?.id ?? '',
        name: values['name'] as String,
        description: values['description'] as String?,
        durationDays: int.tryParse(values['durationDays']?.toString() ?? '') ??
            0,
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

      if (success && context.mounted) {
        showSuccessSnackBar(
          context,
          message:
              isEditing ? 'Membership plan updated' : 'Membership plan created',
          useRootMessenger: false,
        );
        Navigator.of(context).pop(true);
      } else if (context.mounted) {
        showErrorSnackBar(
          context,
          message: isEditing
              ? 'Failed to update membership plan'
              : 'Failed to create membership plan',
          useRootMessenger: false,
        );
      }
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            isEditing
                                ? 'Edit Membership Plan'
                                : 'New Membership Plan',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: isSaving.value ? null : handleSave,
                          child: isSaving.value
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Text('Save'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Form
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      child: FormBuilder(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FormBuilderTextField(
                              name: 'name',
                              initialValue: membership?.name,
                              decoration: const InputDecoration(
                                  labelText: 'Plan Name *'),
                              validator: FormBuilderValidators.required(),
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'description',
                              initialValue: membership?.description,
                              decoration: const InputDecoration(
                                  labelText: 'Description'),
                              maxLines: 2,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'durationDays',
                              initialValue:
                                  membership?.durationDays.toString() ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Duration (days) *',
                                helperText:
                                    'e.g. 30 for monthly, 365 for annual',
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
                              initialValue:
                                  membership?.price.toString() ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Price *',
                                prefixText: '\u20B1 ',
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
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
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
