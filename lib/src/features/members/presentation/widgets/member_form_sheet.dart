import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../../domain/member.dart';
import '../controllers/members_controller.dart';
import '../controllers/paginated_members_controller.dart';

/// Shows a bottom sheet form for creating or editing a member.
///
/// Returns `true` if the member was saved successfully.
Future<bool?> showMemberFormSheet(
  BuildContext context, {
  Member? member,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _MemberFormSheet(member: member),
  );
}

class _MemberFormSheet extends HookConsumerWidget {
  const _MemberFormSheet({this.member});

  final Member? member;

  bool get isEditing => member != null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);

    Future<void> handleSave() async {
      if (!formKey.currentState!.saveAndValidate()) return;

      isSaving.value = true;
      final values = formKey.currentState!.value;

      final memberData = Member(
        id: member?.id ?? '',
        name: values['name'] as String,
        mobileNumber: values['mobileNumber'] as String?,
        email: values['email'] as String?,
        dateOfBirth: values['dateOfBirth'] as DateTime?,
        sex: values['sex'] as MemberSex?,
        address: values['address'] as String?,
        emergencyContact: values['emergencyContact'] as String?,
        remarks: values['remarks'] as String?,
        rfidCardId: member?.rfidCardId,
        addedBy: member?.addedBy,
      );

      final controller = ref.read(membersControllerProvider.notifier);

      bool success;
      if (isEditing) {
        success = await controller.updateMember(memberData);
      } else {
        final created = await controller.createMember(memberData);
        success = created != null;
      }

      // Also refresh paginated list
      ref.read(paginatedMembersControllerProvider.notifier).refresh();

      isSaving.value = false;

      if (success && context.mounted) {
        showSuccessSnackBar(
          context,
          message: isEditing ? 'Member updated' : 'Member created',
          useRootMessenger: false,
        );
        Navigator.of(context).pop(true);
      } else if (context.mounted) {
        showErrorSnackBar(
          context,
          message: isEditing
              ? 'Failed to update member'
              : 'Failed to create member',
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
                            isEditing ? 'Edit Member' : 'New Member',
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
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
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
                              initialValue: member?.name,
                              decoration:
                                  const InputDecoration(labelText: 'Name *'),
                              validator: FormBuilderValidators.required(),
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'mobileNumber',
                              initialValue: member?.mobileNumber,
                              decoration: const InputDecoration(
                                  labelText: 'Mobile Number'),
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'email',
                              initialValue: member?.email,
                              decoration:
                                  const InputDecoration(labelText: 'Email'),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 16),
                            FormBuilderDateTimePicker(
                              name: 'dateOfBirth',
                              initialValue: member?.dateOfBirth,
                              decoration: const InputDecoration(
                                  labelText: 'Date of Birth'),
                              inputType: InputType.date,
                              firstDate: DateTime(1900),
                              lastDate: DateTime.now(),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderDropdown<MemberSex>(
                              name: 'sex',
                              initialValue: member?.sex,
                              decoration:
                                  const InputDecoration(labelText: 'Sex'),
                              items: MemberSex.values
                                  .map((s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s.displayName),
                                      ))
                                  .toList(),
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'address',
                              initialValue: member?.address,
                              decoration:
                                  const InputDecoration(labelText: 'Address'),
                              maxLines: 2,
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.sentences,
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'emergencyContact',
                              initialValue: member?.emergencyContact,
                              decoration: const InputDecoration(
                                  labelText: 'Emergency Contact'),
                              textInputAction: TextInputAction.next,
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: 16),
                            FormBuilderTextField(
                              name: 'remarks',
                              initialValue: member?.remarks,
                              decoration:
                                  const InputDecoration(labelText: 'Remarks'),
                              maxLines: 3,
                              textCapitalization: TextCapitalization.sentences,
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
