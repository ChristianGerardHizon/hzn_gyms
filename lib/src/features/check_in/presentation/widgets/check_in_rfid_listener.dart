import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../domain/card_check_in_result.dart';
import '../../domain/editable_text_focus.dart';
import '../../domain/rfid_keyboard_wedge_decoder.dart';
import '../../domain/rfid_wedge_candidate_key.dart';
import '../controllers/check_in_controller.dart';
import '../controllers/rfid_listener_status.dart';
import 'check_in_error_dialog.dart';
import 'check_in_success_dialog.dart';

/// Listens for HID keyboard-wedge RFID/barcode scans on Check-In.
///
/// Scanning starts **on** while this page is mounted and the app/window has
/// OS focus. When focus is lost, a fullscreen "Not in focus" overlay is shown
/// and the keyboard handler is detached. Keystrokes are not stolen from a
/// focused search field.
class CheckInRfidListener extends ConsumerStatefulWidget {
  const CheckInRfidListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<CheckInRfidListener> createState() =>
      _CheckInRfidListenerState();
}

class _CheckInRfidListenerState extends ConsumerState<CheckInRfidListener>
    with WindowListener, WidgetsBindingObserver {
  final _decoder = RfidKeyboardWedgeDecoder();
  bool _isProcessing = false;
  bool _dialogOpen = false;
  bool _handlerAttached = false;
  bool _windowFocused = true;
  bool _desktopWindowListener = false;

  /// Cached EditableText focus — updated via [FocusManager], not per keystroke.
  bool _editableFocused = false;

  static bool get _isDesktop {
    if (kIsWeb) return false;
    return {
      TargetPlatform.linux,
      TargetPlatform.macOS,
      TargetPlatform.windows,
    }.contains(defaultTargetPlatform);
  }

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_onFocusChange);
    WidgetsBinding.instance.addObserver(this);
    if (_isDesktop) {
      windowManager.addListener(this);
      _desktopWindowListener = true;
    }
    // Attach as soon as the first frame settles so the page is scan-ready.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _onFocusChange();
      _syncListeningState();
      // Prefer unfocused search field so wedge keys never hit the TextField.
      FocusManager.instance.primaryFocus?.unfocus();
    });
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_onFocusChange);
    WidgetsBinding.instance.removeObserver(this);
    if (_desktopWindowListener) {
      windowManager.removeListener(this);
      _desktopWindowListener = false;
    }
    _detachHandler();
    try {
      ref.read(rfidListenerStatusControllerProvider.notifier).disable();
    } catch (_) {}
    super.dispose();
  }

  @override
  void onWindowFocus() {
    _setWindowFocused(true);
  }

  @override
  void onWindowBlur() {
    _setWindowFocused(false);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Desktop uses WindowListener; lifecycle covers mobile/web tab blur.
    if (_isDesktop) return;
    _setWindowFocused(state == AppLifecycleState.resumed);
  }

  void _setWindowFocused(bool focused) {
    if (_windowFocused == focused) return;
    _windowFocused = focused;
    if (!_windowFocused) {
      _decoder.reset();
    }
    _syncListeningState();
    if (mounted) setState(() {});
  }

  void _onFocusChange() {
    // FocusManager may still notify during teardown; skip if we are gone.
    if (!mounted) return;
    final next = isEditableTextFocusContext(
      FocusManager.instance.primaryFocus?.context,
    );
    if (next == _editableFocused) return;
    _editableFocused = next;
    if (_editableFocused) {
      _decoder.reset();
    }
  }

  /// Clears partial wedge characters that reached a focused text field.
  void _clearFocusedEditableInput() {
    final focus = FocusManager.instance.primaryFocus;
    final context = focus?.context;
    if (context != null && context.mounted) {
      final editable = context.findAncestorStateOfType<EditableTextState>();
      editable?.widget.controller.clear();
    }
    focus?.unfocus();
  }

  void _syncListeningState() {
    if (!mounted) return;
    final notifier = ref.read(rfidListenerStatusControllerProvider.notifier);
    if (_windowFocused) {
      notifier.enable();
      _attachHandler();
    } else {
      notifier.pause();
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
    if (!_windowFocused) return false;
    if (_isProcessing || _dialogOpen) return false;

    if (!isRfidWedgeCandidateKey(
      logicalKey: event.logicalKey,
      character: event.character,
    )) {
      return false;
    }

    // Still decode while a text field is focused so USB wedge scans work
    // without requiring the NFC icon or an empty focus. Human typing stays
    // slow enough that scan-mode (≤60ms gaps) does not engage.
    return _decoder.handleKeyDown(
      logicalKey: event.logicalKey,
      character: event.character,
      now: DateTime.now(),
      onScan: (cardId) {
        // Drop leftover first chars that may have reached the search field.
        _clearFocusedEditableInput();
        Future<void>(() => _processScan(cardId));
      },
    );
  }

  Future<void> _requestFocus() async {
    if (_isDesktop) {
      try {
        await windowManager.focus();
      } catch (_) {}
    }
    _setWindowFocused(true);
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
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (!_windowFocused)
          Positioned.fill(
            child: _NotInFocusOverlay(onResume: _requestFocus),
          ),
      ],
    );
  }
}

class _NotInFocusOverlay extends StatelessWidget {
  const _NotInFocusOverlay({required this.onResume});

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: colorScheme.surface.withValues(alpha: 0.92),
      child: InkWell(
        onTap: onResume,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.desktop_access_disabled_outlined,
                  size: 72,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 24),
                Text(
                  'Not in focus',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Click or tap here to resume RFID scanning',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
