import 'package:flutter/material.dart';

/// Whether the current focus target is an [EditableText] (or inside one).
///
/// Returns false when [focusContext] is null or already unmounted — FocusManager
/// can notify after the focused element's widget has been cleared, and reading
/// [BuildContext.widget] then throws (null check on `_widget`).
bool isEditableTextFocusContext(BuildContext? focusContext) {
  if (focusContext == null || !focusContext.mounted) return false;
  return focusContext.widget is EditableText ||
      focusContext.findAncestorStateOfType<EditableTextState>() != null;
}
