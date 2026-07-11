import 'package:flutter/material.dart';

/// A standardized error state display widget.
///
/// Used when data loading fails, showing an error message
/// with an optional retry button.
///
/// Example:
/// ```dart
/// ErrorState(
///   message: 'Failed to load members',
///   onRetry: () => ref.read(controller.notifier).refresh(),
/// )
/// ```
///
/// Without retry button:
/// ```dart
/// ErrorState(
///   message: 'Unable to connect to server',
/// )
/// ```
class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.icon = Icons.error_outline,
    this.iconSize = 64,
  });

  /// The error message to display.
  final String message;

  /// Callback when retry button is pressed. If null, no retry button is shown.
  final VoidCallback? onRetry;

  /// Label for the retry button. Defaults to 'Retry'.
  final String retryLabel;

  /// The error icon. Defaults to [Icons.error_outline].
  final IconData icon;

  /// Size of the error icon. Defaults to 64.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: iconSize,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
