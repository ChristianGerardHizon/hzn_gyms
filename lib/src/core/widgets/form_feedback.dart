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

/// Shows a floating success snackbar with a check icon.
///
/// Used for displaying success messages after form submissions.
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
  _getMessenger(context, useRootMessenger: useRootMessenger).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.green,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(16),
      duration: duration,
      showCloseIcon: true,
      closeIconColor: Colors.white,
    ),
  );
}

/// Shows a floating error snackbar with an error icon.
///
/// Used for displaying quick error messages (use [showFormErrorDialog] for
/// detailed validation errors).
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
  _getMessenger(context, useRootMessenger: useRootMessenger).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: SelectableText(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.red,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(16),
      duration: duration,
      showCloseIcon: true,
      closeIconColor: Colors.white,
    ),
  );
}

/// Shows a floating info snackbar with an info icon.
///
/// Used for displaying informational messages (e.g., "Refreshing...").
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
  _getMessenger(context, useRootMessenger: useRootMessenger).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(16),
      duration: duration,
      showCloseIcon: true,
      closeIconColor: Colors.white,
    ),
  );
}

/// Shows a floating warning snackbar with a warning icon.
///
/// Used for displaying warning messages (e.g., "Feature coming soon").
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
  _getMessenger(context, useRootMessenger: useRootMessenger).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.warning_amber, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Text(message)),
        ],
      ),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.orange,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.all(16),
      duration: duration,
      showCloseIcon: true,
      closeIconColor: Colors.white,
    ),
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
