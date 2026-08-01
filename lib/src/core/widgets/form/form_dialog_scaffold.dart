import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import '../../hooks/use_form_dirty_guard.dart';
import '../../utils/breakpoints.dart';
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
    this.initialValue,
    this.isSaving = false,
    this.saveEnabled = true,
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

  /// Initial values passed to the underlying [FormBuilder].
  ///
  /// Useful for edit forms whose fields rely on form-level initial values
  /// rather than per-field `initialValue`.
  final Map<String, dynamic>? initialValue;

  /// Whether a save operation is in progress.
  final bool isSaving;

  /// Whether the save button is enabled (when not saving).
  final bool saveEnabled;

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
    final isMobile = MediaQuery.sizeOf(context).width < Breakpoints.mobile;

    // On mobile or when explicitly full-screen, the dialog fills the available
    // space and the form scrolls inside an [Expanded]. On tablet/desktop the
    // dialog shrink-wraps its content (up to the constrained max height) so it
    // renders as a compact, centered card rather than a near-full-height panel.
    final expand = fullScreen || isMobile;

    final header = FormDialogHeader(
      title: title,
      isSaving: isSaving,
      saveEnabled: saveEnabled,
      onClose: () async {
        if (await dirtyGuard.confirmDiscard(context)) {
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      onSave: onSave,
      saveLabel: saveLabel,
      cancelLabel: cancelLabel,
      showCancelButton: showCancelButton,
    );

    final formContent = <Widget>[
      const SizedBox(height: 16),
      child,
      const SizedBox(height: 24),
    ];

    final Widget form = expand
        ? SingleChildScrollView(
            padding: contentPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: formContent,
            ),
          )
        // shrinkWrap lets the scroll view size to its content while still
        // scrolling once the content exceeds the dialog's max height.
        : ListView(
            shrinkWrap: true,
            padding: contentPadding,
            children: formContent,
          );

    final column = Column(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        header,
        const SizedBox(height: 8),
        expand
            ? Expanded(
                child: FormBuilder(
                  key: formKey,
                  initialValue: initialValue ?? const {},
                  child: form,
                ),
              )
            : Flexible(
                child: FormBuilder(
                  key: formKey,
                  initialValue: initialValue ?? const {},
                  child: form,
                ),
              ),
      ],
    );

    // A local [Scaffold] is only needed in expand mode so in-dialog snackbars
    // render above the full-height panel. In shrink-wrap mode a Scaffold would
    // force the dialog back to full height, so it is intentionally omitted.
    final Widget body = expand
        ? ScaffoldMessenger(child: Scaffold(body: column))
        : column;

    return DialogCloseHandler(
      onClose: (ctx) => dirtyGuard.confirmDiscard(ctx),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: dirtyGuard.onPopInvokedWithResult,
        child: ConstrainedDialogContent(
          maxWidth: maxWidth,
          fullScreen: fullScreen,
          child: body,
        ),
      ),
    );
  }
}
