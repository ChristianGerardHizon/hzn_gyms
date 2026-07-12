import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundation/error_display.dart';
import '../../i18n/strings.g.dart';

/// A standardized error state display widget.
///
/// Used when data loading fails, showing a friendly title, selectable
/// message/details, optional copy action, and an optional retry button.
///
/// Example:
/// ```dart
/// ErrorState.fromError(
///   error,
///   onRetry: () => ref.read(controller.notifier).refresh(),
/// )
/// ```
///
/// Simple message-only:
/// ```dart
/// ErrorState(
///   message: 'Unable to connect to server',
///   onRetry: () => ...,
/// )
/// ```
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.title,
    this.details,
    this.statusCode,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.icon = Icons.error_outline,
    this.compact = false,
  }) : _copyText = null;

  /// Builds an [ErrorState] from any thrown object / [Failure] / HTTP error.
  factory ErrorState.fromError(
    Object error, {
    Key? key,
    VoidCallback? onRetry,
    String? title,
    String retryLabel = 'Retry',
    IconData icon = Icons.error_outline,
    bool compact = false,
    Translations? translations,
  }) {
    final info = ErrorDisplayInfo.from(error, translations: translations);
    return ErrorState._internal(
      key: key,
      title: title ?? info.title,
      message: info.message,
      details: info.details,
      statusCode: info.statusCode,
      onRetry: onRetry,
      retryLabel: retryLabel,
      icon: icon,
      compact: compact,
      copyText: info.copyText,
    );
  }

  const ErrorState._internal({
    super.key,
    required this.message,
    this.title,
    this.details,
    this.statusCode,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.icon = Icons.error_outline,
    this.compact = false,
    required String? copyText,
  }) : _copyText = copyText;

  /// Friendly title above the message. Defaults to a generic error label.
  final String? title;

  /// The primary error message to display (selectable).
  final String message;

  /// Optional technical details (selectable, monospace).
  final String? details;

  /// Optional HTTP status code shown as a chip.
  final int? statusCode;

  /// Callback when retry button is pressed. If null, no retry button is shown.
  final VoidCallback? onRetry;

  /// Label for the retry button. Defaults to 'Retry'.
  final String retryLabel;

  /// The error icon. Defaults to [Icons.error_outline].
  final IconData icon;

  /// Compact layout for tabs/panels (smaller icon, tighter padding).
  final bool compact;

  final String? _copyText;

  String get _resolvedCopyText =>
      _copyText ??
      [
        if (title != null && title!.isNotEmpty) title!,
        message,
        if (details != null && details!.isNotEmpty) details!,
        if (statusCode != null) 'HTTP $statusCode',
      ].where((s) => s.isNotEmpty).join('\n\n');

  Future<void> _copy(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _resolvedCopyText));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error details copied'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconSize = compact ? 40.0 : 56.0;
    final padding = compact ? 16.0 : 24.0;
    final maxWidth = compact ? 420.0 : 520.0;
    final displayTitle = title ?? 'Something went wrong';

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(compact ? 12 : 16),
                decoration: BoxDecoration(
                  color: colorScheme.errorContainer.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: colorScheme.error,
                ),
              ),
              SizedBox(height: compact ? 12 : 20),
              if (statusCode != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'HTTP $statusCode',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              SelectableText(
                displayTitle,
                style: (compact
                        ? theme.textTheme.titleMedium
                        : theme.textTheme.titleLarge)
                    ?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              if (message.isNotEmpty && message != displayTitle) ...[
                SizedBox(height: compact ? 8 : 12),
                SelectableText(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (details != null && details!.isNotEmpty) ...[
                SizedBox(height: compact ? 12 : 16),
                _DetailsCard(
                  details: details!,
                  compact: compact,
                  onCopy: () => _copy(context),
                ),
              ] else ...[
                const SizedBox(height: 8),
                IconButton(
                  tooltip: 'Copy error',
                  onPressed: () => _copy(context),
                  icon: const Icon(Icons.copy_outlined, size: 20),
                ),
              ],
              if (onRetry != null) ...[
                SizedBox(height: compact ? 12 : 20),
                FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(retryLabel),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({
    required this.details,
    required this.compact,
    required this.onCopy,
  });

  final String details;
  final bool compact;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final maxHeight = compact ? 120.0 : 180.0;

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 4, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Details',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Copy error',
                  onPressed: onCopy,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.copy_outlined, size: 18),
                ),
              ],
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: SelectableText(
                details,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
