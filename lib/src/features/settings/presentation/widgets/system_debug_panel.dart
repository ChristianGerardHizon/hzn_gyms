import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/routes/check_in.routes.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../check_in/domain/card_check_in_result.dart';
import '../../../check_in/presentation/controllers/check_in_controller.dart';
import '../../../check_in/presentation/controllers/rfid_listener_status.dart';
import '../../../check_in/presentation/widgets/check_in_error_dialog.dart';
import '../../../check_in/presentation/widgets/check_in_success_dialog.dart';

/// System debug tools, including RFID check-in simulation.
class SystemDebugPanel extends HookConsumerWidget {
  const SystemDebugPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSimulating = useState(false);
    final listenerStatus = ref.watch(rfidListenerStatusControllerProvider);
    final isListening = listenerStatus == RfidListenerStatus.listening;
    final isPaused = listenerStatus == RfidListenerStatus.paused;
    final isTablet = Breakpoints.isTabletOrLarger(context);

    Future<void> handleSimulate() async {
      if (!formKey.currentState!.saveAndValidate()) return;
      final values = formKey.currentState!.value;
      final cardId = (values['cardId'] as String?)?.trim() ?? '';
      if (cardId.isEmpty) return;

      isSimulating.value = true;
      try {
        // RFID HardwareKeyboard listener mounts on Check-In / Dashboard;
        // debug runs the same check-in + dialog path directly.
        final result = await ref
            .read(checkInControllerProvider.notifier)
            .cardCheckIn(cardValue: cardId);

        if (!context.mounted) return;

        switch (result) {
          case CardCheckInSuccess(
            :final memberName,
            :final membershipName,
            :final membershipEndDate,
            :final membershipDaysRemaining,
          ):
            await showCheckInSuccessDialog(
              context,
              memberName: memberName,
              hasActiveMembership: true,
              membershipName: membershipName,
              membershipEndDate: membershipEndDate,
              membershipDaysRemaining: membershipDaysRemaining,
            );
          case CardCheckInCardNotFound():
            await showCheckInErrorDialog(
              context,
              title: 'Card Not Found',
              message:
                  'No member matches card "$cardId". '
                  'Check that the card is registered.',
            );
          case CardCheckInNoActiveMembership(:final memberName):
            await showCheckInErrorDialog(
              context,
              title: 'No Active Membership',
              message:
                  '$memberName has no active membership and cannot check in.',
            );
          case CardCheckInMembershipNotValidAtBranch(:final memberName):
            await showCheckInErrorDialog(
              context,
              title: 'Not Valid at This Branch',
              message:
                  '$memberName has an active membership, but it is not valid '
                  'at this branch.',
            );
          case CardCheckInNoBranch():
            await showCheckInErrorDialog(
              context,
              title: 'Select a Branch',
              message:
                  'Choose a specific branch before checking in with RFID. '
                  '"All branches" cannot be used for check-in.',
            );
          case CardCheckInFailed():
            await showCheckInErrorDialog(
              context,
              title: 'Check-In Failed',
              message: 'Something went wrong while recording the check-in.',
            );
        }
      } finally {
        if (context.mounted) {
          isSimulating.value = false;
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
        automaticallyImplyLeading: !isTablet,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'RFID check-in',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Runs the same card check-in + success/error dialogs used by the '
            'Check-In RFID listener (without needing a USB reader).',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: Icon(
                Icons.nfc,
                color: isListening
                    ? Colors.green
                    : Colors.red,
              ),
              title: Text(
                isListening
                    ? 'Hardware listener active (on Check-In)'
                    : isPaused
                    ? 'Hardware listener paused (Check-In not in focus)'
                    : 'Hardware listener inactive',
              ),
              subtitle: Text(
                isListening
                    ? 'USB reader is listening on Check-In while the window is focused.'
                    : isPaused
                    ? 'Open Check-In and focus the window to resume USB scanning.'
                    : 'Open Check-In to enable USB scanning automatically. '
                        'This debug button still works here.',
              ),
              trailing: TextButton(
                onPressed: () => const CheckInRoute().go(context),
                child: const Text('Open'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          FormBuilder(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FormBuilderTextField(
                  name: 'cardId',
                  decoration: const InputDecoration(
                    labelText: 'Card value *',
                    hintText: 'e.g. 12345678',
                    helperText:
                        'Use the exact string stored on the member card.',
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(4),
                  ]),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!isSimulating.value) handleSimulate();
                  },
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: isSimulating.value ? null : handleSimulate,
                  icon: isSimulating.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.nfc),
                  label: Text(
                    isSimulating.value
                        ? 'Simulating…'
                        : 'Simulate RFID check-in',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Tips',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• On Check-In, USB RFID listens automatically while the window is focused.\n'
            '• Pick a specific branch before check-in; "All branches" is blocked.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
