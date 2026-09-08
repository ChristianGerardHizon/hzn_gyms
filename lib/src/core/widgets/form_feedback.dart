import 'package:flutter/material.dart';

import '../i18n/strings.g.dart';
import '../routing/router.dart';

/// Gets the ScaffoldMessenger to use for snackbars.
///
/// When [useRootMessenger] is true (default), uses the root ScaffoldMessenger
/// so snackbars appear at the app level. When false, uses the nearest
/// ScaffoldMessenger from [context] — useful when called from dialogs that
/// want the snackbar to appear within their own scaffold.
ScaffoldMessengerState _getMessenger(
  BuildContext context, {
  bool useRootMessenger = true,
}) {
  if (useRootMessenger) {
    return rootScaffoldMessengerKey.currentState ??
        ScaffoldMessenger.of(context);
  }
  return ScaffoldMessenger.of(context);
}

/// Shows an error dialog with a list of validation errors.
///
/// Used for displaying form validation errors in a user-friendly popup.
///
/// Example:
/// ```dart
/// showFormErrorDialog(
///   context,
///   errors: ['Name is required', 'Email is invalid'],
///   title: 'Validation Errors', // optional
/// );
/// ```
void showFormErrorDialog(
  BuildContext context, {
  required List<String> errors,
  String title = 'Validation Errors',
}) {
  final theme = Theme.of(context);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: errors
            .map((error) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\u2022 ',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                      Expanded(child: SelectableText(error)),
                    ],
                  ),
                ))
            .toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

(Color bg, Color fg) _statusColors(BuildContext context, _StatusTone tone) {
  final scheme = Theme.of(context).colorScheme;
  final isDark = scheme.brightness == Brightness.dark;
  return switch (tone) {
    _StatusTone.success => (
        // ColorScheme has no success token.
        isDark ? const Color(0xFF1B4332) : const Color(0xFFDCFCE7),
        isDark ? const Color(0xFFB7E4C7) : const Color(0xFF1B4332),
      ),
    _StatusTone.error => (scheme.errorContainer, scheme.onErrorContainer),
    _StatusTone.info => (scheme.primaryContainer, scheme.onPrimaryContainer),
    // ColorScheme has no warning token.
    _StatusTone.warning => (
        isDark ? const Color(0xFF4A3000) : const Color(0xFFFFE8C2),
        isDark ? const Color(0xFFFFD591) : const Color(0xFF4A3000),
      ),
  };
}

void _showStatusSnackBar(
  BuildContext context, {
  required String message,
  required IconData icon,
  required _StatusTone tone,
  required Duration duration,
  required bool useRootMessenger,
  bool selectable = false,
}) {
  final (bg, fg) = _statusColors(context, tone);
  _getMessenger(context, useRootMessenger: useRootMessenger).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: selectable
                ? SelectableText(message, style: TextStyle(color: fg))
                : Text(message, style: TextStyle(color: fg)),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: bg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      margin: const EdgeInsets.all(16),
      duration: duration,
      showCloseIcon: true,
      closeIconColor: fg,
    ),
  );
}

enum _StatusTone { success, error, info, warning }

/// Shows a floating success snackbar with a check icon.
///
/// Example:
/// ```dart
/// showSuccessSnackBar(context, message: 'Member created successfully');
/// ```
void showSuccessSnackBar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 3),
  bool useRootMessenger = true,
}) {
  _showStatusSnackBar(
    context,
    message: message,
    icon: Icons.check_circle,
    tone: _StatusTone.success,
    duration: duration,
    useRootMessenger: useRootMessenger,
  );
}

/// Shows a floating error snackbar with an error icon.
///
/// Example:
/// ```dart
/// showErrorSnackBar(context, message: 'Failed to save');
/// ```
void showErrorSnackBar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 4),
  bool useRootMessenger = true,
}) {
  _showStatusSnackBar(
    context,
    message: message,
    icon: Icons.error_outline,
    tone: _StatusTone.error,
    duration: duration,
    useRootMessenger: useRootMessenger,
    selectable: true,
  );
}

/// Shows a floating info snackbar with an info icon.
///
/// Example:
/// ```dart
/// showInfoSnackBar(context, message: 'Refreshing data...');
/// ```
void showInfoSnackBar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 3),
  bool useRootMessenger = true,
}) {
  _showStatusSnackBar(
    context,
    message: message,
    icon: Icons.info_outline,
    tone: _StatusTone.info,
    duration: duration,
    useRootMessenger: useRootMessenger,
  );
}

/// Shows a floating warning snackbar with a warning icon.
///
/// Example:
/// ```dart
/// showWarningSnackBar(context, message: 'Feature coming soon');
/// ```
void showWarningSnackBar(
  BuildContext context, {
  required String message,
  Duration duration = const Duration(seconds: 4),
  bool useRootMessenger = true,
}) {
  _showStatusSnackBar(
    context,
    message: message,
    icon: Icons.warning_amber,
    tone: _StatusTone.warning,
    duration: duration,
    useRootMessenger: useRootMessenger,
  );
}

/// Helper to convert form field errors to user-friendly messages.
///
/// Pass a map of field name to label mappings.
///
/// Example:
/// ```dart
/// final labels = {'name': 'Member Name', 'email': 'Email Address'};
/// final messages = formatFormErrors(formKey.currentState?.errors ?? {}, labels);
/// if (messages.isNotEmpty) {
///   showFormErrorDialog(context, errors: messages);
/// }
/// ```
List<String> formatFormErrors(
  Map<String, String> errors,
  Map<String, String> fieldLabels,
) {
  return errors.entries
      .where((e) => e.value.isNotEmpty)
      .map((e) => '${fieldLabels[e.key] ?? e.key}: ${e.value}')
      .toList();
}

/// Shows a confirmation dialog for discarding unsaved changes.
///
/// Returns true if user confirms discard, false otherwise.
///
/// Example:
/// ```dart
/// if (await showDiscardChangesDialog(context)) {
///   Navigator.pop(context);
/// }
/// ```
Future<bool> showDiscardChangesDialog(BuildContext context) async {
  final t = Translations.of(context);

  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t.common.discardChanges),
      content: Text(t.common.discardChangesMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(t.common.keepEditing),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(t.common.discard),
        ),
      ],
    ),
  );

  return result ?? false;
}
