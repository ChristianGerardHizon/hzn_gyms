import 'package:flutter/material.dart';

/// A standardized empty state display widget.
///
/// Used when there's no data to display, such as:
/// - No member selected in tablet layout
/// - Empty list results
/// - No search results
///
/// Example:
/// ```dart
/// EmptyState(
///   icon: Icons.person_outline,
///   title: 'No Member Selected',
///   subtitle: 'Select a member from the list to view details',
/// )
/// ```
///
/// With action button:
/// ```dart
/// EmptyState(
///   icon: Icons.inventory_2_outlined,
///   title: 'No Products',
///   subtitle: 'Add your first product to get started',
///   action: FilledButton.icon(
///     onPressed: () => showCreateProductDialog(context),
///     icon: const Icon(Icons.add),
///     label: const Text('Add Product'),
///   ),
/// )
/// ```
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
    this.iconSize = 80,
  });

  /// The icon displayed at the top.
  final IconData icon;

  /// The main title text.
  final String title;

  /// Optional subtitle text.
  final String? subtitle;

  /// Optional action widget (typically a button).
  final Widget? action;

  /// Size of the icon. Defaults to 80.
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: iconSize,
            color: theme.colorScheme.outlineVariant,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: 24),
            action!,
          ],
        ],
      ),
    );
  }
}
