import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import '../../../check_in/domain/rfid_keyboard_wedge_decoder.dart';
import '../../../check_in/domain/rfid_wedge_candidate_key.dart';

/// How the card ID is being captured in [MemberCardEntryForm].
enum MemberCardEntryMode {
  /// Waiting for a USB keyboard-wedge RFID scan.
  waitingForScan,

  /// A card ID was captured from a scan.
  scanned,

  /// User is typing the card ID manually.
  manual,
}

/// Whether a card entry form has a captured card ID ready to submit.
bool memberCardEntryCanSubmit(MemberCardEntryMode mode) =>
    mode != MemberCardEntryMode.waitingForScan;

/// Shared scan-first card entry fields used by [AddCardDialog] and the new-member wizard.
///
/// Must be placed inside an existing [FormBuilder] (via [FormDialogScaffold] or a
/// parent [FormBuilder] widget).
class MemberCardEntryForm extends HookWidget {
  const MemberCardEntryForm({
    super.key,
    required this.formKey,
    required this.entryMode,
  });

  final GlobalKey<FormBuilderState> formKey;
  final ValueNotifier<MemberCardEntryMode> entryMode;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final decoder = useMemoized(RfidKeyboardWedgeDecoder.new);
    useListenable(entryMode);

    void setCardValue(String? value) {
      formKey.currentState?.fields['cardValue']?.didChange(value);
    }

    void goToWaitingForScan() {
      decoder.reset();
      entryMode.value = MemberCardEntryMode.waitingForScan;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setCardValue(null);
        FocusManager.instance.primaryFocus?.unfocus();
      });
    }

    useEffect(() {
      if (entryMode.value != MemberCardEntryMode.waitingForScan) {
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
            entryMode.value = MemberCardEntryMode.scanned;
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

    return Column(
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
                case MemberCardEntryMode.waitingForScan:
                  return _ScanWaitingPanel(
                    onEnterManually: () {
                      decoder.reset();
                      entryMode.value = MemberCardEntryMode.manual;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setCardValue(null);
                      });
                    },
                  );
                case MemberCardEntryMode.scanned:
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
                case MemberCardEntryMode.manual:
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
          if (entryMode.value != MemberCardEntryMode.waitingForScan) ...[
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
