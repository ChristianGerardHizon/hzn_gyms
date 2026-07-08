import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/form/form_dialog_scaffold.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../controllers/member_cards_controller.dart';

/// Shows a dialog form for adding a new member card.
///
/// Returns `true` if the card was added successfully.
Future<bool?> showAddCardDialog(
  BuildContext context, {
  required String memberId,
}) {
  return showConstrainedDialog<bool>(
    context: context,
    builder: (context) => AddCardDialog(memberId: memberId),
  );
}

class AddCardDialog extends HookConsumerWidget {
  const AddCardDialog({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);

    final dirtyGuard = useFormDirtyGuard(formKey: formKey);

    Future<void> handleSave(BuildContext dialogContext) async {
      if (!formKey.currentState!.saveAndValidate()) return;

      isSaving.value = true;
      final values = formKey.currentState!.value;

      final success = await ref
          .read(memberCardsControllerProvider(memberId).notifier)
          .addCard(
            cardValue: values['cardValue'] as String,
            label: values['label'] as String?,
            notes: values['notes'] as String?,
          );

      isSaving.value = false;

      if (success && dialogContext.mounted) {
        showSuccessSnackBar(
          dialogContext,
          message: 'Card added successfully',
          useRootMessenger: false,
        );
        Navigator.of(dialogContext).pop(true);
      } else if (dialogContext.mounted) {
        showErrorSnackBar(
          dialogContext,
          message: 'Failed to add card. The card value may already be in use.',
          useRootMessenger: false,
        );
      }
    }

    return FormDialogScaffold(
      title: 'Add Card',
      formKey: formKey,
      dirtyGuard: dirtyGuard,
      isSaving: isSaving.value,
      onSave: handleSave,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormBuilderTextField(
            name: 'cardValue',
            decoration: const InputDecoration(
              labelText: 'Card ID / Value *',
              helperText: 'The unique identifier on the physical card',
              prefixIcon: Icon(Icons.credit_card),
            ),
            validator: FormBuilderValidators.required(),
            textInputAction: TextInputAction.next,
            autofocus: true,
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'label',
            decoration: const InputDecoration(
              labelText: 'Label',
              helperText: 'Optional name (e.g., "Primary Card")',
            ),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          FormBuilderTextField(
            name: 'notes',
            decoration: const InputDecoration(
              labelText: 'Notes',
            ),
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
          ),
        ],
      ),
    );
  }
}
