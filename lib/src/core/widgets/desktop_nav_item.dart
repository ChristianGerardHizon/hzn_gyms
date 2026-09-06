import 'package:flutter/material.dart';

/// A single sidebar row with optional pill highlight for the active route.
class DesktopNavItem extends StatelessWidget {
  const DesktopNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.collapsed = false,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool collapsed;
  final Widget? trailing;

  static const double expandedHeight = 40;
  static const double collapsedSize = 44;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final content = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: collapsed ? collapsedSize : expandedHeight,
          padding: EdgeInsets.symmetric(
            horizontal: collapsed ? 0 : 12,
          ),
          decoration: BoxDecoration(
            color: selected ? colorScheme.secondaryContainer : null,
            borderRadius: BorderRadius.circular(24),
          ),
          child: collapsed
              ? Center(
                  child: Icon(
                    icon,
                    size: 22,
                    color: selected
                        ? colorScheme.onSecondaryContainer
                        : colorScheme.onSurfaceVariant,
                  ),
                )
              : Row(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: selected
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: selected
                              ? colorScheme.onSecondaryContainer
                              : colorScheme.onSurface,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trailing != null) trailing!,
                  ],
                ),
        ),
      ),
    );

    if (collapsed) {
      return Tooltip(message: label, child: content);
    }
    return content;
  }
}

/// Muted section header for sidebar groups.
class DesktopNavSectionHeader extends StatelessWidget {
  const DesktopNavSectionHeader({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
