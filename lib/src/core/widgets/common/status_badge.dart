import 'package:flutter/material.dart';

/// Variants for the [StatusBadge] widget.
enum StatusBadgeVariant {
  /// Filled background with contrasting text.
  filled,

  /// Subtle background with matching text color.
  subtle,

  /// Outlined border with no background fill.
  outlined,
}

/// A standardized status badge/chip widget.
///
/// Used to display status indicators throughout the app,
/// such as sale status, membership status, stock levels, etc.
///
/// Example:
/// ```dart
/// StatusBadge(
///   label: 'Completed',
///   color: Colors.green,
///   icon: Icons.check,
/// )
/// ```
///
/// With variant:
/// ```dart
/// StatusBadge(
///   label: 'Low Stock',
///   color: Colors.orange,
///   icon: Icons.warning,
///   variant: StatusBadgeVariant.subtle,
/// )
/// ```
///
/// Icon only:
/// ```dart
/// StatusBadge.iconOnly(
///   icon: Icons.check_circle,
///   color: Colors.green,
///   tooltip: 'Paid',
/// )
/// ```
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
    this.variant = StatusBadgeVariant.subtle,
    this.tooltip,
  }) : _iconOnly = false;

  const StatusBadge.iconOnly({
    super.key,
    required this.icon,
    required this.color,
    this.tooltip,
  })  : label = '',
        variant = StatusBadgeVariant.subtle,
        _iconOnly = true;

  /// The label text to display.
  final String label;

  /// The primary color for the badge.
  final Color color;

  /// Optional icon displayed before the label.
  final IconData? icon;

  /// The visual variant of the badge.
  final StatusBadgeVariant variant;

  /// Optional tooltip text.
  final String? tooltip;

  final bool _iconOnly;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color backgroundColor;
    Color foregroundColor;
    Border? border;

    switch (variant) {
      case StatusBadgeVariant.filled:
        backgroundColor = color;
        foregroundColor = _contrastColor(color);
        break;
      case StatusBadgeVariant.subtle:
        backgroundColor = color.withValues(alpha: 0.1);
        foregroundColor = color;
        break;
      case StatusBadgeVariant.outlined:
        backgroundColor = Colors.transparent;
        foregroundColor = color;
        border = Border.all(color: color);
        break;
    }

    Widget badge;

    if (_iconOnly) {
      badge = Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: border,
        ),
        child: Icon(
          icon,
          size: 16,
          color: foregroundColor,
        ),
      );
    } else {
      badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: border,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: foregroundColor,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: foregroundColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: badge,
      );
    }

    return badge;
  }

  /// Returns white or black based on luminance for contrast.
  Color _contrastColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
}
