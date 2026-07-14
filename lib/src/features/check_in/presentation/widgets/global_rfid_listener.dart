import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/card_check_in_result.dart';
import '../controllers/check_in_controller.dart';
import '../controllers/rfid_listener_status.dart';
import 'check_in_error_dialog.dart';
import 'check_in_success_dialog.dart';

/// Listens for HID keyboard-wedge RFID/barcode scans app-wide when logged in.
///
/// Scanners type characters rapidly and end with Enter. Human typing is ignored
/// via inter-key gap detection.
class GlobalRfidListener extends ConsumerStatefulWidget {
  const GlobalRfidListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<GlobalRfidListener> createState() => _GlobalRfidListenerState();
}

class _GlobalRfidListenerState extends ConsumerState<GlobalRfidListener> {
  static const _maxInterKeyGap = Duration(milliseconds: 80);
  static const _minCardLength = 4;

  final _buffer = StringBuffer();
  DateTime? _lastKeyTime;
  bool _inScanMode = false;
  bool _isProcessing = false;
  bool _dialogOpen = false;
  bool _handlerAttached = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _attachListener());
  }

  @override
  void dispose() {
    _detachListener();
    super.dispose();
  }

  void _attachListener() {
    if (!mounted) return;

    if (kIsWeb) {
      ref
          .read(rfidListenerStatusControllerProvider.notifier)
          .setUnavailable();
      return;
    }

    if (_handlerAttached) return;

    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
    _handlerAttached = true;
    ref.read(rfidListenerStatusControllerProvider.notifier).setListening();
  }

  void _detachListener() {
    if (_handlerAttached) {
      HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
      _handlerAttached = false;
    }
    // Provider may already be disposed if the whole app is tearing down.
    try {
      ref
          .read(rfidListenerStatusControllerProvider.notifier)
          .setUnavailable();
    } catch (_) {}
  }

  void _resetBuffer() {
    _buffer.clear();
    _lastKeyTime = null;
    _inScanMode = false;
  }

  /// True when an editable text field currently has focus.
  bool _isTextInputFocused() {
    final focus = FocusManager.instance.primaryFocus;
    final context = focus?.context;
    if (context == null) return false;
    return context.widget is EditableText ||
        context.findAncestorStateOfType<EditableTextState>() != null;
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (_isProcessing || _dialogOpen) return false;

    // Never steal keystrokes from focused text fields (search, login, POS).
    if (_isTextInputFocused()) {
      _resetBuffer();
      return false;
    }

    final isEnter =
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;

    if (isEnter) {
      final cardValue = _buffer.toString().trim();
      final isScan = _inScanMode && cardValue.length >= _minCardLength;
      _resetBuffer();
      if (isScan) {
        _processScan(cardValue);
        return true;
      }
      return false;
    }

    final character = event.character;
    if (character == null ||
        character.isEmpty ||
        character == '\n' ||
        character == '\r') {
      return false;
    }

    // Ignore pure control characters.
    if (character.codeUnitAt(0) < 32) return false;

    final now = DateTime.now();
    if (_lastKeyTime != null &&
        now.difference(_lastKeyTime!) > _maxInterKeyGap) {
      _resetBuffer();
    }

    if (_lastKeyTime != null &&
        now.difference(_lastKeyTime!) <= _maxInterKeyGap) {
      _inScanMode = true;
    }

    _buffer.write(character);
    _lastKeyTime = now;

    // Once we treat input as a scanner burst, consume keys so they do not
    // leak into unfocused widgets.
    return _inScanMode;
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
        case CardCheckInSuccess(:final memberName):
          await showCheckInSuccessDialog(
            context,
            memberName: memberName,
            hasActiveMembership: true,
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
  Widget build(BuildContext context) => widget.child;
}
