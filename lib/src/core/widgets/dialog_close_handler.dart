import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Handles keyboard escape key for dialog dismissal.
///
/// Wraps dialog content to intercept Escape key presses and either:
/// - Close immediately (if [onClose] is null or returns true)
/// - Show confirmation dialog (if [onClose] returns false initially)
///
/// Without [onClose], uses [Navigator.maybePop] (not go_router `context.pop`)
/// so overlay dialogs close reliably even when the shell route cannot pop.
///
/// After a confirmed [onClose], uses [Navigator.pop] so a child
/// [PopScope] with `canPop: false` does not re-prompt (maybePop would).
///
/// Usage with dirty guard:
/// ```dart
/// return DialogCloseHandler(
///   onClose: (ctx) => dirtyGuard.confirmDiscard(ctx),
///   child: PopScope(
///     canPop: false,
///     onPopInvokedWithResult: dirtyGuard.onPopInvokedWithResult,
///     child: Column(/* dialog content */),
///   ),
/// );
/// ```
///
/// Usage without dirty guard (immediate close):
/// ```dart
/// return DialogCloseHandler(
///   child: Column(/* dialog content */),
/// );
/// ```
class DialogCloseHandler extends StatelessWidget {
  const DialogCloseHandler({
    super.key,
    required this.child,
    this.onClose,
    this.enabled = true,
  });

  /// The dialog content to wrap.
  final Widget child;

  /// Called when user presses Escape.
  /// Returns true to close, false to prevent closing.
  /// If null, defaults to immediate close.
  final Future<bool> Function(BuildContext context)? onClose;

  /// Whether escape key handling is enabled.
  final bool enabled;

  Future<void> _handleDismiss(BuildContext context) async {
    if (onClose != null) {
      final shouldClose = await onClose!(context);
      if (shouldClose && context.mounted) {
        Navigator.of(context).pop();
      }
      return;
    }
    await Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.escape): DismissIntent(),
      },
      child: Actions(
        actions: {
          DismissIntent: CallbackAction<DismissIntent>(
            onInvoke: (_) {
              _handleDismiss(context);
              return null;
            },
          ),
        },
        // Also handle Escape via focus bubbling so it still works when a
        // TextField (e.g. member search on Renew) has primary focus.
        child: Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (!enabled) return KeyEventResult.ignored;
            if (event is! KeyDownEvent) return KeyEventResult.ignored;
            if (event.logicalKey != LogicalKeyboardKey.escape) {
              return KeyEventResult.ignored;
            }
            _handleDismiss(context);
            return KeyEventResult.handled;
          },
          child: child,
        ),
      ),
    );
  }
}
