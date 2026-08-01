import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/form/form_dialog_scaffold.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../domain/member_membership.dart';
import '../controllers/member_memberships_controller.dart';

/// Shows a dialog to edit start/end dates for a member membership.
Future<bool?> showEditMemberMembershipDatesDialog(
  BuildContext context, {
  required MemberMembership memberMembership,
}) {
  return showConstrainedDialog<bool>(
    context: context,
    maxWidth: DialogConstraints.compactMaxWidth,
    barrierDismissible: false,
    builder: (context) => EditMemberMembershipDatesDialog(
      memberMembership: memberMembership,
    ),
  );
}

/// Dialog for manually editing membership start and end dates.
class EditMemberMembershipDatesDialog extends HookConsumerWidget {
  const EditMemberMembershipDatesDialog({
    super.key,
    required this.memberMembership,
  });

  final MemberMembership memberMembership;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialStart = toLocalDateOnly(memberMembership.startDate);
    final initialEnd = toLocalDateOnly(memberMembership.endDate);

    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final dirtyGuard = useFormDirtyGuard(
      formKey: formKey,
      initialValues: {
        'startDate': initialStart,
        'endDate': initialEnd,
      },
    );
    final isSaving = useState(false);

    Future<void> handleSave(BuildContext dialogContext) async {
      if (!formKey.currentState!.saveAndValidate()) {
        final errors = formKey.currentState?.errors ?? {};
        final errorMessages = formatFormErrors(errors, _fieldLabels);
        if (errorMessages.isNotEmpty) {
          showFormErrorDialog(dialogContext, errors: errorMessages);
        }
        return;
      }

      final values = formKey.currentState!.value;
      final startDate = toLocalDateOnly(values['startDate'] as DateTime);
      final endDate = toLocalDateOnly(values['endDate'] as DateTime);

      if (endDate.isBefore(startDate)) {
        showFormErrorDialog(
          dialogContext,
          errors: ['End date must be on or after start date'],
        );
        return;
      }

      isSaving.value = true;

      final error = await ref
          .read(
            memberMembershipsControllerProvider(
              memberMembership.memberId,
            ).notifier,
          )
          .updateMembershipDates(
            memberMembership.id,
            startDate: startDate,
            endDate: endDate,
          );

      if (!dialogContext.mounted) return;
      isSaving.value = false;

      if (error != null) {
        showFormErrorDialog(dialogContext, errors: [error]);
        return;
      }

      context.pop(true);
      if (context.mounted) {
        showSuccessSnackBar(context, message: 'Membership dates updated');
      }
    }

    return FormDialogScaffold(
      title: 'Edit Dates',
      formKey: formKey,
      dirtyGuard: dirtyGuard,
      isSaving: isSaving.value,
      onSave: handleSave,
      maxWidth: DialogConstraints.compactMaxWidth,
      saveLabel: 'Save',
      initialValue: {
        'startDate': initialStart,
        'endDate': initialEnd,
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormBuilderDateTimePicker(
            name: 'startDate',
            decoration: const InputDecoration(
              labelText: 'Start Date *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            enabled: !isSaving.value,
            inputType: InputType.date,
            firstDate: DateTime(2000),
            lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
            validator: FormBuilderValidators.required(
              errorText: 'Start date is required',
            ),
          ),
          const SizedBox(height: 16),
          FormBuilderDateTimePicker(
            name: 'endDate',
            decoration: const InputDecoration(
              labelText: 'End Date *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.event),
            ),
            enabled: !isSaving.value,
            inputType: InputType.date,
            firstDate: DateTime(2000),
            lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(errorText: 'End date is required'),
              (value) {
                if (value == null) return null;
                final start =
                    formKey.currentState?.fields['startDate']?.value
                        as DateTime?;
                if (start == null) return null;
                if (toLocalDateOnly(value).isBefore(toLocalDateOnly(start))) {
                  return 'End date must be on or after start date';
                }
                return null;
              },
            ]),
          ),
        ],
      ),
    );
  }
}

const _fieldLabels = {'startDate': 'Start Date', 'endDate': 'End Date'};
