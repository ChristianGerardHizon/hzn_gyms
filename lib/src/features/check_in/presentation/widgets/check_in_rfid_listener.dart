import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/card_check_in_result.dart';
import '../../domain/rfid_keyboard_wedge_decoder.dart';
import '../../domain/rfid_wedge_candidate_key.dart';
import '../controllers/check_in_controller.dart';
import '../controllers/rfid_listener_status.dart';
import 'check_in_error_dialog.dart';
import 'check_in_success_dialog.dart';

/// Optionally listens for HID keyboard-wedge RFID/barcode scans on Check-In.
///
/// Scanning starts **off**. Enable it via [RfidListenerStatusController]
/// (NFC icon in the Check-In app bar). Keystrokes are not stolen from a
/// focused search field.
class CheckInRfidListener extends ConsumerStatefulWidget {
  const CheckInRfidListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<CheckInRfidListener> createState() =>
      _CheckInRfidListenerState();
}

class _CheckInRfidListenerState extends ConsumerState<CheckInRfidListener> {
  final _decoder = RfidKeyboardWedgeDecoder();
  bool _isProcessing = false;
  bool _dialogOpen = false;
  bool _handlerAttached = false;

  /// Cached EditableText focus — updated via [FocusManager], not per keystroke.
  bool _editableFocused = false;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _onFocusChange();
      // Always start disabled when opening Check-In.
      ref.read(rfidListenerStatusControllerProvider.notifier).disable();
    });
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_onFocusChange);
    _detachHandler();
    try {
      ref.read(rfidListenerStatusControllerProvider.notifier).disable();
    } catch (_) {}
    super.dispose();
  }

  void _onFocusChange() {
    final next = _computeEditableFocused();
    if (next == _editableFocused) return;
    _editableFocused = next;
    if (_editableFocused) {
      _decoder.reset();
    }
  }

  bool _computeEditableFocused() {
    final focus = FocusManager.instance.primaryFocus;
    final context = focus?.context;
    if (context == null) return false;
    return context.widget is EditableText ||
        context.findAncestorStateOfType<EditableTextState>() != null;
  }

  void _syncHandler(RfidListenerStatus status) {
    if (status == RfidListenerStatus.listening) {
      _attachHandler();
    } else {
      _detachHandler();
    }
  }

  void _attachHandler() {
    if (!mounted || _handlerAttached) return;
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    _handlerAttached = true;
  }

  void _detachHandler() {
    if (!_handlerAttached) return;
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _handlerAttached = false;
    _decoder.reset();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (_isProcessing || _dialogOpen || _editableFocused) return false;

    if (!isRfidWedgeCandidateKey(
      logicalKey: event.logicalKey,
      character: event.character,
    )) {
      return false;
    }

    return _decoder.handleKeyDown(
      logicalKey: event.logicalKey,
      character: event.character,
      now: DateTime.now(),
      onScan: (cardId) {
        Future<void>(() => _processScan(cardId));
      },
    );
  }

  Future<void> _processScan(String cardValue) async {
    if (_isProcessing || !mounted) return;
    _isProcessing = true;

    try {
      final result = await ref
          .read(checkInControllerProvider.notifier)
          .cardCheckIn(cardValue: cardValue);

      if (!mounted) return;

      _dialogOpen = true;
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
                'No member matches card "$cardValue". '
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
      _dialogOpen = false;
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(rfidListenerStatusControllerProvider, (previous, next) {
      _syncHandler(next);
    });
    return widget.child;
  }
}
