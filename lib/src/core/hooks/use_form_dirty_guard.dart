import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../widgets/form_feedback.dart';

/// Result object returned by [useFormDirtyGuard].
class FormDirtyGuardResult {
  const FormDirtyGuardResult({
    required this.checkDirty,
    required this.confirmDiscard,
    required this.onPopInvokedWithResult,
  });

  /// Check if the form currently has unsaved changes.
  final bool Function() checkDirty;

  /// Shows a confirmation dialog and returns true if user wants to discard.
  /// Returns true immediately if the form is not dirty.
  final Future<bool> Function(BuildContext context) confirmDiscard;

  /// Callback to use with PopScope.onPopInvokedWithResult.
  /// Handles showing the discard confirmation dialog when form is dirty.
  final void Function(bool didPop, Object? result) onPopInvokedWithResult;
}

/// Hook that tracks form dirty state and provides discard confirmation.
///
/// For create forms (no initial entity):
/// ```dart
/// final dirtyGuard = useFormDirtyGuard(formKey: formKey);
/// ```
///
/// For edit forms (editing existing entity):
/// ```dart
/// final dirtyGuard = useFormDirtyGuard(
///   formKey: formKey,
///   initialValues: {'name': user.name, 'username': user.username},
/// );
/// ```
///
/// Then wrap your sheet content with PopScope:
/// ```dart
/// return PopScope(
///   canPop: false,
///   onPopInvokedWithResult: dirtyGuard.onPopInvokedWithResult,
///   child: YourSheetContent(),
/// );
/// ```
///
/// And update the cancel button:
/// ```dart
/// TextButton(
///   onPressed: () async {
///     if (await dirtyGuard.confirmDiscard(context)) {
///       if (context.mounted) Navigator.pop(context);
///     }
///   },
///   child: Text('Cancel'),
/// ),
/// ```
FormDirtyGuardResult useFormDirtyGuard({
  required GlobalKey<FormBuilderState> formKey,
  Map<String, dynamic>? initialValues,
  bool enabled = true,
}) {
  // Track if we're currently showing a dialog to prevent multiple dialogs
  bool isShowingDialog = false;

  // Check if form has changes from initial values
  bool checkDirty() {
    if (!enabled) return false;

    final state = formKey.currentState;
    if (state == null) return false;

    final currentValues = state.instantValue;

    if (initialValues == null) {
      // Create form: dirty if any field has a non-empty value
      return currentValues.entries.any((entry) {
        final value = entry.value;
        if (value == null) return false;
        if (value is String) return value.trim().isNotEmpty;
        if (value is List) return value.isNotEmpty;
        return true; // Non-null, non-string, non-list values count as dirty
      });
    }

    // Edit form: dirty if values differ from initial
    const equality = DeepCollectionEquality();

    // Compare each field
    for (final entry in currentValues.entries) {
      final key = entry.key;
      final currentValue = entry.value;
      final initialValue = initialValues[key];

      // Normalize empty strings to null for comparison
      final normalizedCurrent =
          (currentValue is String && currentValue.trim().isEmpty)
              ? null
              : currentValue;
      final normalizedInitial =
          (initialValue is String && initialValue.trim().isEmpty)
              ? null
              : initialValue;

      if (!equality.equals(normalizedCurrent, normalizedInitial)) {
        return true;
      }
    }

    return false;
  }

  Future<bool> confirmDiscard(BuildContext context) async {
    if (!checkDirty() || !enabled) return true;
    if (isShowingDialog) return false;

    isShowingDialog = true;
    try {
      return await showDiscardChangesDialog(context);
    } finally {
      isShowingDialog = false;
    }
  }

  void onPopInvokedWithResult(bool didPop, Object? result) {
    if (didPop) return; // Already popped, nothing to do

    // Get context from form key
    final context = formKey.currentContext;
    if (context == null) return;

    // If form is not dirty or guard is disabled, just pop
    if (!checkDirty() || !enabled) {
      Navigator.of(context).pop();
      return;
    }

    // Show confirmation dialog
    confirmDiscard(context).then((shouldDiscard) {
      if (shouldDiscard && context.mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  return FormDirtyGuardResult(
    checkDirty: checkDirty,
    confirmDiscard: confirmDiscard,
    onPopInvokedWithResult: onPopInvokedWithResult,
  );
}
