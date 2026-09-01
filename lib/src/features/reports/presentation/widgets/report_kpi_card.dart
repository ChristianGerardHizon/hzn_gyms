import 'package:flutter/material.dart';

/// A KPI card for the reports page with left accent border, icon bubble,
/// uppercase title, and optional featured gradient variant.
class ReportKpiCard extends StatelessWidget {
  const ReportKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.featured = false,
    this.compact = false,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  /// When true, uses a color gradient background with white text.
  final bool featured;

  /// When true, uses tighter padding and smaller value/icon for sub-details.
  final bool compact;

  /// Optional tap handler (e.g. open a transactions breakdown dialog).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = featured ? Colors.white : theme.colorScheme.onSurface;
    final subtitleColor = featured
        ? Colors.white70
        : theme.colorScheme.onSurfaceVariant;
    final accentColor = featured ? Colors.white.withAlpha(60) : color;
    final padding = compact ? 10.0 : 14.0;
    final titleGap = compact ? 4.0 : 8.0;
    final iconPadding = compact ? 6.0 : 8.0;
    final iconSize = compact ? 16.0 : 20.0;
    final valueStyle = (compact
            ? theme.textTheme.titleLarge
            : theme.textTheme.headlineSmall)
        ?.copyWith(
      color: textColor,
      fontWeight: FontWeight.bold,
    );

    final content = IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left accent bar
          Container(width: 4, color: accentColor),
          // Content
          Expanded(
            child: Container(
              decoration: featured
                  ? BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [color.withAlpha(220), color.withAlpha(180)],
                      ),
                    )
                  : null,
              padding: EdgeInsets.all(padding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: featured ? Colors.white70 : color,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: titleGap),
                        Text(
                          value,
                          style: valueStyle,
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: subtitleColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Icon bubble
                  Container(
                    padding: EdgeInsets.all(iconPadding),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: featured
                          ? Colors.white.withAlpha(40)
                          : color.withAlpha(30),
                    ),
                    child: Icon(
                      icon,
                      size: iconSize,
                      color: featured ? Colors.white : color,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: featured ? 2 : 1,
      shadowColor: featured ? color.withAlpha(80) : null,
      child: onTap == null
          ? content
          : InkWell(
              onTap: onTap,
              child: content,
            ),
    );
  }
}
