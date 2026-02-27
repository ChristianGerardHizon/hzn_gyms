import 'package:flutter/material.dart';

import '../../i18n/strings.g.dart';

/// A standardized header for form dialogs.
///
/// Provides a consistent header with:
/// - Close button (left)
/// - Title (center/expanded)
/// - Cancel button
/// - Save button with loading state
///
/// Example:
/// ```dart
/// FormDialogHeader(
///   title: 'Create Product',
///   isSaving: isSaving.value,
///   onClose: () async {
///     if (await dirtyGuard.confirmDiscard(context)) {
///       context.pop();
///     }
///   },
///   onSave: handleSave,
/// )
/// ```
class FormDialogHeader extends StatelessWidget {
  const FormDialogHeader({
    super.key,
    required this.title,
    required this.onClose,
    required this.onSave,
    this.isSaving = false,
    this.saveLabel,
    this.cancelLabel,
    this.showCancelButton = true,
  });

  /// The title displayed in the header.
  final String title;

  /// Called when the close button or cancel button is pressed.
  /// Should handle dirty form confirmation if needed.
  final VoidCallback onClose;

  /// Called when the save button is pressed.
  ///
  /// Receives a [BuildContext] below the dialog's [ScaffoldMessenger] so
  /// snackbar calls with `useRootMessenger: false` render above the dialog.
  final ValueChanged<BuildContext> onSave;

  /// Whether a save operation is in progress.
  /// Disables buttons and shows a loading indicator on the save button.
  final bool isSaving;

  /// Custom label for the save button. Defaults to localized "Save".
  final String? saveLabel;

  /// Custom label for the cancel button. Defaults to localized "Cancel".
  final String? cancelLabel;

  /// Whether to show the cancel button. Defaults to true.
  final bool showCancelButton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: isSaving ? null : onClose,
          ),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleLarge,
            ),
          ),
          if (showCancelButton) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: isSaving ? null : onClose,
                child: Text(cancelLabel ?? t.common.cancel),
              ),
            ),
          ],
          FilledButton(
            onPressed: isSaving ? null : () => onSave(context),
            child: isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(saveLabel ?? t.common.save),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
