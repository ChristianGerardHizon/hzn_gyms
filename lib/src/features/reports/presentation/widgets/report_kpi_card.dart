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
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;

  /// When true, uses a blue gradient background with white text.
  final bool featured;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = featured ? Colors.white : theme.colorScheme.onSurface;
    final subtitleColor =
        featured ? Colors.white70 : theme.colorScheme.onSurfaceVariant;
    final accentColor = featured ? Colors.white.withAlpha(60) : color;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: featured ? 2 : 1,
      shadowColor: featured ? color.withAlpha(80) : null,
      child: IntrinsicHeight(
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
                          colors: [
                            color.withAlpha(220),
                            color.withAlpha(180),
                          ],
                        ),
                      )
                    : null,
                padding: const EdgeInsets.all(14),
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
                          const SizedBox(height: 8),
                          Text(
                            value,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: featured
                            ? Colors.white.withAlpha(40)
                            : color.withAlpha(30),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: featured ? Colors.white : color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
