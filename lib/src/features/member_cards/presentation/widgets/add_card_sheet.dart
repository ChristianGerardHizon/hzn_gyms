import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/form_feedback.dart';
import '../controllers/member_cards_controller.dart';

/// Shows a bottom sheet form for adding a new member card.
///
/// Returns `true` if the card was added successfully.
Future<bool?> showAddCardSheet(
  BuildContext context, {
  required String memberId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _AddCardSheet(memberId: memberId),
  );
}

class _AddCardSheet extends HookConsumerWidget {
  const _AddCardSheet({required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);

    Future<void> handleSave() async {
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

      if (success && context.mounted) {
        showSuccessSnackBar(
          context,
          message: 'Card added successfully',
          useRootMessenger: false,
        );
        Navigator.of(context).pop(true);
      } else if (context.mounted) {
        showErrorSnackBar(
          context,
          message: 'Failed to add card. The card value may already be in use.',
          useRootMessenger: false,
        );
      }
    }

    return ScaffoldMessenger(
      child: Builder(
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.85,
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
                            'Add Card',
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
                              name: 'cardValue',
                              decoration: const InputDecoration(
                                labelText: 'Card ID / Value *',
                                helperText:
                                    'The unique identifier on the physical card',
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
                                helperText:
                                    'Optional name (e.g., "Primary Card")',
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
