import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../hooks/use_form_dirty_guard.dart';
import '../dialog/dialog_constraints.dart';
import '../dialog_close_handler.dart';
import 'form_dialog_header.dart';

/// A standardized scaffold for form dialogs.
///
/// Combines the common dialog structure:
/// - [DialogCloseHandler] for Escape key handling
/// - [PopScope] with dirty guard integration
/// - Full-screen sizing
/// - [FormDialogHeader] with title and action buttons
/// - Scrollable [FormBuilder] content area
///
/// Example:
/// ```dart
/// FormDialogScaffold(
///   title: 'Create Product',
///   formKey: formKey,
///   dirtyGuard: dirtyGuard,
///   isSaving: isSaving.value,
///   onSave: handleSave,
///   child: Column(
///     children: [
///       FormBuilderTextField(name: 'name', ...),
///       // ... more fields
///     ],
///   ),
/// )
/// ```
class FormDialogScaffold extends StatelessWidget {
  const FormDialogScaffold({
    super.key,
    required this.title,
    required this.formKey,
    required this.dirtyGuard,
    required this.onSave,
    required this.child,
    this.isSaving = false,
    this.saveLabel,
    this.cancelLabel,
    this.showCancelButton = true,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 24),
    this.fullScreen = false,
    this.maxWidth = DialogConstraints.defaultMaxWidth,
  });

  /// The title displayed in the header.
  final String title;

  /// The form key for the [FormBuilder].
  final GlobalKey<FormBuilderState> formKey;

  /// The dirty guard result from [useFormDirtyGuard].
  final FormDirtyGuardResult dirtyGuard;

  /// Called when the save button is pressed.
  ///
  /// Receives a [BuildContext] below the dialog's [ScaffoldMessenger] so
  /// snackbar calls with `useRootMessenger: false` render above the dialog.
  final ValueChanged<BuildContext> onSave;

  /// The form content (fields).
  final Widget child;

  /// Whether a save operation is in progress.
  final bool isSaving;

  /// Custom label for the save button.
  final String? saveLabel;

  /// Custom label for the cancel button.
  final String? cancelLabel;

  /// Whether to show the cancel button.
  final bool showCancelButton;

  /// Padding for the scrollable content area.
  final EdgeInsets contentPadding;

  /// Forces full-screen mode regardless of screen size.
  /// Recommended for complex forms with 10+ fields.
  final bool fullScreen;

  /// Maximum width for the dialog on tablet/desktop.
  /// Ignored when [fullScreen] is true or on mobile.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return DialogCloseHandler(
      onClose: (ctx) => dirtyGuard.confirmDiscard(ctx),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: dirtyGuard.onPopInvokedWithResult,
        child: ConstrainedDialogContent(
          maxWidth: maxWidth,
          fullScreen: fullScreen,
          child: ScaffoldMessenger(
            child: Scaffold(
              body: Column(
                children: [
                  FormDialogHeader(
                    title: title,
                    isSaving: isSaving,
                    onClose: () async {
                      if (await dirtyGuard.confirmDiscard(context)) {
                        if (context.mounted) Navigator.of(context).pop();
                      }
                    },
                    onSave: onSave,
                    saveLabel: saveLabel,
                    cancelLabel: cancelLabel,
                    showCancelButton: showCancelButton,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: FormBuilder(
                      key: formKey,
                      child: SingleChildScrollView(
                        padding: contentPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 16),
                            child,
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
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
