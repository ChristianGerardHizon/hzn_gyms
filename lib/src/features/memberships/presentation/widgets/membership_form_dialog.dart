import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/form/form_dialog_scaffold.dart';
import '../../../../core/widgets/form/form_section_header.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../settings/presentation/controllers/branches_controller.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/membership.dart';
import '../controllers/memberships_controller.dart';

/// Dropdown label for a [MembershipDurationUnit].
String _durationUnitLabel(MembershipDurationUnit unit) {
  switch (unit) {
    case MembershipDurationUnit.days:
      return 'Day(s)';
    case MembershipDurationUnit.weeks:
      return 'Week(s)';
    case MembershipDurationUnit.months:
      return 'Month(s)';
    case MembershipDurationUnit.years:
      return 'Year(s)';
  }
}

/// Whether [selectedBranchIds] covers every id in [allBranchIds].
///
/// Used to auto-enable "Valid at all branches" when every branch is checked.
bool selectsAllBranches(
  Iterable<String> selectedBranchIds,
  Iterable<String> allBranchIds,
) {
  final all = allBranchIds.toList();
  if (all.isEmpty) return false;
  final selected = selectedBranchIds.toSet();
  return all.every(selected.contains);
}

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
    final branchesAsync = ref.watch(branchesControllerProvider);
    final currentBranchId = ref.watch(effectiveBranchIdForWriteProvider);

    final isAllBranches = membership != null
        ? membership!.validBranches.isEmpty
        : false;
    final allBranches = useState(isAllBranches);

    final initialValidBranches = membership != null
        ? (membership!.validBranches.isEmpty
              ? <String>[]
              : List<String>.from(membership!.validBranches))
        : (currentBranchId != null ? [currentBranchId] : <String>[]);

    final initialValues = isEditing
        ? <String, dynamic>{
            'name': membership!.name,
            'description': membership!.description,
            'durationValue': membership!.durationValue.toString(),
            'durationUnit': membership!.durationUnit,
            'price': membership!.price.toString(),
            'isActive': membership!.isActive,
            'isFavorite': membership!.isFavorite,
            'memberNotRequired': membership!.memberNotRequired,
            'allBranches': isAllBranches,
            'validBranches': initialValidBranches,
          }
        : <String, dynamic>{
            'allBranches': false,
            'validBranches': initialValidBranches,
          };

    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: initialValues,
    );

    Future<void> handleSave(BuildContext dialogContext) async {
      if (!formKey.currentState!.saveAndValidate()) return;

      isSaving.value = true;
      final values = formKey.currentState!.value;

      final branchId =
          membership?.branchId ??
          ref.read(effectiveBranchIdForWriteProvider) ??
          '';

      final all = values['allBranches'] as bool? ?? false;
      final selectedRaw = values['validBranches'];
      final selected = selectedRaw is List
          ? selectedRaw.map((e) => e.toString()).toList()
          : <String>[];

      final membershipData = Membership(
        id: membership?.id ?? '',
        name: values['name'] as String,
        description: values['description'] as String?,
        durationValue:
            int.tryParse(values['durationValue']?.toString() ?? '') ?? 0,
        durationUnit:
            values['durationUnit'] as MembershipDurationUnit? ??
            MembershipDurationUnit.days,
        price: num.tryParse(values['price']?.toString() ?? '') ?? 0,
        branchId: branchId,
        validBranches: all ? const [] : selected,
        isActive: values['isActive'] as bool? ?? true,
        isFavorite: values['isFavorite'] as bool? ?? false,
        memberNotRequired: values['memberNotRequired'] as bool? ?? false,
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
          const FormSectionHeader(
            title: 'Plan',
            icon: Icons.card_membership_outlined,
          ),
          const SizedBox(height: 12),
          FormBuilderTextField(
            name: 'name',
            initialValue: membership?.name,
            decoration: const InputDecoration(labelText: 'Plan Name *'),
            validator: FormBuilderValidators.required(),
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          FormBuilderTextField(
            name: 'description',
            initialValue: membership?.description,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: 'durationValue',
                  initialValue: membership?.durationValue.toString() ?? '1',
                  decoration: const InputDecoration(labelText: 'Duration *'),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.integer(),
                    FormBuilderValidators.min(1),
                  ]),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FormBuilderDropdown<MembershipDurationUnit>(
                  name: 'durationUnit',
                  initialValue:
                      membership?.durationUnit ?? MembershipDurationUnit.days,
                  decoration: const InputDecoration(labelText: 'Unit *'),
                  items: MembershipDurationUnit.values
                      .map(
                        (unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(_durationUnitLabel(unit)),
                        ),
                      )
                      .toList(),
                  validator: FormBuilderValidators.required(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FormBuilderTextField(
            name: 'price',
            initialValue: membership?.price.toString() ?? '',
            decoration: const InputDecoration(
              labelText: 'Price *',
              prefixText: '\u20B1 ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(),
              FormBuilderValidators.numeric(),
            ]),
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 24),
          const FormSectionHeader(
            title: 'Branches',
            icon: Icons.store_outlined,
          ),
          const SizedBox(height: 4),
          FormBuilderCheckbox(
            name: 'allBranches',
            initialValue: allBranches.value,
            title: const Text('Valid at all branches'),
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: (value) {
              allBranches.value = value ?? false;
            },
          ),
          if (!allBranches.value) ...[
            branchesAsync.when(
              data: (branches) => FormBuilderCheckboxGroup<String>(
                name: 'validBranches',
                initialValue: initialValidBranches,
                decoration: const InputDecoration(
                  labelText: 'Valid at',
                  border: InputBorder.none,
                ),
                enabled: !isSaving.value,
                orientation: OptionsOrientation.vertical,
                options: branches
                    .map(
                      (branch) => FormBuilderFieldOption(
                        value: branch.id,
                        child: Text(branch.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  final selected = value ?? const <String>[];
                  final allIds = branches.map((b) => b.id);
                  if (!selectsAllBranches(selected, allIds)) return;

                  allBranches.value = true;
                  formKey.currentState?.fields['allBranches']?.didChange(true);
                  formKey.currentState?.fields['validBranches']?.didChange(
                    const <String>[],
                  );
                },
                validator: (value) {
                  if (allBranches.value) return null;
                  if (value == null || value.isEmpty) {
                    return 'Select at least one branch';
                  }
                  return null;
                },
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const Text(
                'Failed to load branches',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ] else
            // Keep the field registered when hidden so save still works
            FormBuilderField<List<String>>(
              name: 'validBranches',
              initialValue: const [],
              builder: (field) => const SizedBox.shrink(),
            ),
          const SizedBox(height: 16),
          const FormSectionHeader(title: 'Options', icon: Icons.tune_outlined),
          FormBuilderSwitch(
            name: 'isActive',
            initialValue: membership?.isActive ?? true,
            title: const Text('Active'),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
          FormBuilderSwitch(
            name: 'isFavorite',
            initialValue: membership?.isFavorite ?? false,
            title: const Text('Favorite'),
            subtitle: const Text('Pin to top of plan lists'),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
          FormBuilderSwitch(
            name: 'memberNotRequired',
            initialValue: membership?.memberNotRequired ?? false,
            title: const Text('Walk-in / day pass'),
            subtitle: const Text('Name only — no linked member'),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ],
      ),
    );
  }
}
