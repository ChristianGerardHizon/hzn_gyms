import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../../../core/widgets/select_branch_for_action_dialog.dart';
import '../../domain/card_check_in_result.dart';
import '../../domain/check_in_block_reason.dart';
import '../../domain/check_in_cooldown.dart';
import '../../domain/editable_text_focus.dart';
import '../../domain/rfid_keyboard_wedge_decoder.dart';
import '../../domain/rfid_wedge_candidate_key.dart';
import '../controllers/check_in_controller.dart';
import '../controllers/rfid_listener_status.dart';
import 'check_in_error_dialog.dart';
import 'check_in_success_dialog.dart';

const _rfidNeedsBranchMessage =
    'Check-in cannot be done while viewing all branches. '
    'Select a branch first.';

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
      _dialogOpen = true;
      final hasBranch = await ensureWritableBranch(
        context,
        ref,
        message: _rfidNeedsBranchMessage,
      );
      if (!hasBranch || !mounted) return;

      final result = await ref
          .read(checkInControllerProvider.notifier)
          .cardCheckIn(cardValue: cardValue);

      if (!mounted) return;

      switch (result) {
        case CardCheckInSuccess(
          :final memberName,
          :final membershipName,
          :final membershipEndDate,
          :final membershipDaysRemaining,
          :final memberPhoto,
        ):
          await showCheckInSuccessDialog(
            context,
            memberName: memberName,
            hasActiveMembership: true,
            membershipName: membershipName,
            membershipEndDate: membershipEndDate,
            membershipDaysRemaining: membershipDaysRemaining,
            memberPhotoUrl: memberPhoto,
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
            title: checkInBlockTitle(CheckInBlockReason.noActiveMembership),
            message: checkInBlockMessage(
              CheckInBlockReason.noActiveMembership,
              memberName,
            ),
          );
        case CardCheckInUnpaidMembership(:final memberName):
          await showCheckInErrorDialog(
            context,
            title: checkInBlockTitle(CheckInBlockReason.unpaidMembership),
            message: checkInBlockMessage(
              CheckInBlockReason.unpaidMembership,
              memberName,
            ),
          );
        case CardCheckInMembershipNotValidAtBranch(:final memberName):
          await showCheckInErrorDialog(
            context,
            title: checkInBlockTitle(CheckInBlockReason.notValidAtBranch),
            message: checkInBlockMessage(
              CheckInBlockReason.notValidAtBranch,
              memberName,
            ),
          );
        case CardCheckInNoBranch():
          // User already dismissed or race while switching — do nothing.
          break;
        case CardCheckInFailed():
          await showCheckInErrorDialog(
            context,
            title: 'Check-In Failed',
            message: 'Could not record check-in. Try again.',
          );
        case CardCheckInCooldown(:final remaining):
          await showCheckInErrorDialog(
            context,
            title: 'Check-In Too Soon',
            message: checkInCooldownMessage(remaining),
          );
      }
    } finally {
      _dialogOpen = false;
      _isProcessing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final showIndicator = !_windowFocused;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned.fill(
          child: AnimatedOpacity(
            opacity: showIndicator ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
            child: IgnorePointer(
              ignoring: !showIndicator,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _requestFocus,
                child: const _InactiveBorderIndicator(),
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: AnimatedSlide(
            offset: showIndicator ? Offset.zero : const Offset(0, -1),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: showIndicator ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: IgnorePointer(
                ignoring: !showIndicator,
                child: _PausedBanner(onResume: _requestFocus),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Draws an animated pulsing border around the entire screen to indicate
/// the window is not focused. Content remains fully visible underneath.
class _InactiveBorderIndicator extends StatefulWidget {
  const _InactiveBorderIndicator();

  @override
  State<_InactiveBorderIndicator> createState() =>
      _InactiveBorderIndicatorState();
}

class _InactiveBorderIndicatorState extends State<_InactiveBorderIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return AnimatedBuilder(
      animation: _opacity,
      builder: (context, child) {
        return IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(
                color: color.withValues(alpha: _opacity.value),
                width: 5,
              ),
            ),
            child: const SizedBox.expand(),
          ),
        );
      },
    );
  }
}

/// A compact top banner indicating RFID scanning is paused.
class _PausedBanner extends StatelessWidget {
  const _PausedBanner({required this.onResume});

  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedOpacity(
      opacity: 1.0,
      duration: const Duration(milliseconds: 250),
      child: Material(
        color: colorScheme.errorContainer,
        elevation: 2,
        child: InkWell(
          onTap: onResume,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sensors_off_outlined,
                    size: 20,
                    color: colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      'RFID scanning paused \u2014 click anywhere to resume',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
