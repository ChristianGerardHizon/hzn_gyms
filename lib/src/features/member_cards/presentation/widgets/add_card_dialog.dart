import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/hooks/use_form_dirty_guard.dart';
import '../../../../core/widgets/dialog/dialog_constraints.dart';
import '../../../../core/widgets/form/form_dialog_scaffold.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../check_in/domain/rfid_keyboard_wedge_decoder.dart';
import '../../../check_in/domain/rfid_wedge_candidate_key.dart';
import '../controllers/member_cards_controller.dart';

/// How the card ID is being captured in [AddCardDialog].
enum AddCardEntryMode {
  /// Waiting for a USB keyboard-wedge RFID scan.
  waitingForScan,

  /// A card ID was captured from a scan.
  scanned,

  /// User is typing the card ID manually.
  manual,
}

/// Shows a dialog form for adding a new member card.
///
/// Starts in scan-first mode; optional label/notes after a scan (or via
/// manual Card ID entry). Returns `true` if the card was added successfully.
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
    final entryMode = useState(AddCardEntryMode.waitingForScan);
    final decoder = useMemoized(RfidKeyboardWedgeDecoder.new);

    final dirtyGuard = useFormDirtyGuard(formKey: formKey);

    void setCardValue(String? value) {
      formKey.currentState?.fields['cardValue']?.didChange(value);
    }

    void goToWaitingForScan() {
      decoder.reset();
      entryMode.value = AddCardEntryMode.waitingForScan;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setCardValue(null);
        FocusManager.instance.primaryFocus?.unfocus();
      });
    }

    useEffect(() {
      if (entryMode.value != AddCardEntryMode.waitingForScan) {
        return null;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusManager.instance.primaryFocus?.unfocus();
      });

      bool handleKeyEvent(KeyEvent event) {
        if (event is! KeyDownEvent) return false;
        if (!isRfidWedgeCandidateKey(
          logicalKey: event.logicalKey,
          character: event.character,
        )) {
          return false;
        }

        return decoder.handleKeyDown(
          logicalKey: event.logicalKey,
          character: event.character,
          now: DateTime.now(),
          onScan: (cardId) {
            entryMode.value = AddCardEntryMode.scanned;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setCardValue(cardId);
            });
          },
        );
      }

      HardwareKeyboard.instance.addHandler(handleKeyEvent);
      return () {
        HardwareKeyboard.instance.removeHandler(handleKeyEvent);
        decoder.reset();
      };
    }, [entryMode.value]);

    Future<void> handleSave(BuildContext dialogContext) async {
      if (!formKey.currentState!.saveAndValidate()) return;

      isSaving.value = true;
      final values = formKey.currentState!.value;

      final success = await ref
          .read(memberCardsControllerProvider(memberId).notifier)
          .addCard(
            cardValue: (values['cardValue'] as String).trim(),
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

    final theme = Theme.of(context);
    final canSave = entryMode.value != AddCardEntryMode.waitingForScan;

    return FormDialogScaffold(
      title: 'Add Card',
      formKey: formKey,
      dirtyGuard: dirtyGuard,
      isSaving: isSaving.value,
      saveEnabled: canSave,
      onSave: handleSave,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FormBuilderField<String>(
            name: 'cardValue',
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'Scan a card or enter a Card ID',
              ),
              FormBuilderValidators.minLength(
                RfidKeyboardWedgeDecoder.minCardLength,
                errorText:
                    'Card ID must be at least '
                    '${RfidKeyboardWedgeDecoder.minCardLength} characters',
              ),
            ]),
            builder: (field) {
              switch (entryMode.value) {
                case AddCardEntryMode.waitingForScan:
                  return _ScanWaitingPanel(
                    onEnterManually: () {
                      decoder.reset();
                      entryMode.value = AddCardEntryMode.manual;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setCardValue(null);
                      });
                    },
                  );
                case AddCardEntryMode.scanned:
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Card ID',
                          prefixIcon: const Icon(Icons.credit_card),
                          errorText: field.errorText,
                          border: const OutlineInputBorder(),
                        ),
                        child: Text(
                          field.value ?? '',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: goToWaitingForScan,
                          icon: const Icon(Icons.nfc, size: 18),
                          label: const Text('Scan again'),
                        ),
                      ),
                    ],
                  );
                case AddCardEntryMode.manual:
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        initialValue: field.value,
                        decoration: InputDecoration(
                          labelText: 'Card ID / Value *',
                          helperText:
                              'The unique identifier on the physical card',
                          prefixIcon: const Icon(Icons.credit_card),
                          errorText: field.errorText,
                        ),
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        onChanged: field.didChange,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: goToWaitingForScan,
                          icon: const Icon(Icons.nfc, size: 18),
                          label: const Text('Use scanner instead'),
                        ),
                      ),
                    ],
                  );
              }
            },
          ),
          if (entryMode.value != AddCardEntryMode.waitingForScan) ...[
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
        ],
      ),
    );
  }
}

class _ScanWaitingPanel extends StatelessWidget {
  const _ScanWaitingPanel({required this.onEnterManually});

  final VoidCallback onEnterManually;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              children: [
                Icon(
                  Icons.nfc,
                  size: 48,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Scan card',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the card on the USB reader to capture its ID.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.center,
          child: TextButton(
            onPressed: onEnterManually,
            child: const Text('Enter Card ID manually'),
          ),
        ),
      ],
    );
  }
}
