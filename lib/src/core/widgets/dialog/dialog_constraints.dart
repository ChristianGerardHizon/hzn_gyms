import 'package:flutter/material.dart';

import '../../utils/breakpoints.dart';

/// Centralized dialog width constraints for tablet/desktop responsiveness.
///
/// On mobile (< 600px), dialogs remain full-screen.
/// On tablet/desktop, dialogs are constrained to a max-width and centered.
abstract class DialogConstraints {
  /// Compact dialog max width (500px).
  /// Use for simple dialogs like sort, search fields, confirmations.
  static const double compactMaxWidth = 500;

  /// Default dialog max width (700px).
  /// Use for standard forms with moderate fields.
  static const double defaultMaxWidth = 700;

  /// Large dialog max width (900px).
  /// Use for dialogs that need more horizontal space.
  static const double largeMaxWidth = 900;

  /// Returns the appropriate inset padding for a dialog.
  ///
  /// On mobile or fullScreen, uses minimal padding (8dp).
  /// On tablet/desktop, calculates horizontal padding to center the dialog.
  static EdgeInsets getInsetPadding(
    BuildContext context, {
    double maxWidth = defaultMaxWidth,
    bool fullScreen = false,
  }) {
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < Breakpoints.mobile;

    if (isMobile || fullScreen) {
      return const EdgeInsets.all(8);
    }

    // Calculate horizontal padding to center the constrained dialog
    final horizontalPadding =
        ((size.width - maxWidth) / 2).clamp(16.0, double.infinity);
    return EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: 24,
    );
  }
}

/// Wraps dialog content with responsive width constraints.
///
/// On mobile (< 600px), expands to full screen.
/// On tablet/desktop, constrains width to [maxWidth] and uses intrinsic height.
///
/// Example:
/// ```dart
/// ConstrainedDialogContent(
///   maxWidth: DialogConstraints.defaultMaxWidth,
///   child: Column(children: [...]),
/// )
/// ```
class ConstrainedDialogContent extends StatelessWidget {
  const ConstrainedDialogContent({
    super.key,
    required this.child,
    this.maxWidth = DialogConstraints.defaultMaxWidth,
    this.fullScreen = false,
  });

  /// The dialog content to wrap.
  final Widget child;

  /// Maximum width for the dialog on tablet/desktop.
  /// Ignored when [fullScreen] is true or on mobile.
  final double maxWidth;

  /// Forces full-screen mode regardless of screen size.
  /// Use for complex forms with many fields.
  final bool fullScreen;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isMobile = size.width < Breakpoints.mobile;

    if (fullScreen || isMobile) {
      // Full screen mode
      return SizedBox(
        width: size.width,
        height: size.height,
        child: child,
      );
    }

    // Pin width on tablet/desktop so Expanded children don't stretch to the
    // full inset area. Height stays loose so shrink-wrap forms stay compact.
    final width = maxWidth.clamp(0.0, size.width - 32);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: width,
        minHeight: 200,
        maxHeight: size.height * 0.9,
      ),
      child: SizedBox(width: width, child: child),
    );
  }
}

/// Shows a dialog with tablet-friendly constraints.
///
/// By default, dialogs are constrained to 700px width on tablet/desktop
/// and centered. On mobile, they remain full-screen.
///
/// Set [fullScreen] to true for complex forms with many fields (10+).
///
/// Example:
/// ```dart
/// showConstrainedDialog(
///   context: context,
///   maxWidth: DialogConstraints.compactMaxWidth,
///   builder: (context) => const SortDialog(),
/// );
/// ```
Future<T?> showConstrainedDialog<T>({
  required BuildContext context,
  required Widget Function(BuildContext) builder,
  bool fullScreen = false,
  double maxWidth = DialogConstraints.defaultMaxWidth,
  bool barrierDismissible = false,
  bool useRootNavigator = true,
}) {
  return showDialog<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    barrierDismissible: barrierDismissible,
    builder: (context) => Dialog(
      insetPadding: DialogConstraints.getInsetPadding(
        context,
        maxWidth: maxWidth,
        fullScreen: fullScreen,
      ),
      clipBehavior: Clip.antiAlias,
      child: builder(context),
    ),
  );
}
