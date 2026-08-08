import 'package:flutter/material.dart';

/// Compact empty-state card for report chart sections with no data.
class ReportNoDataCard extends StatelessWidget {
  const ReportNoDataCard({
    super.key,
    this.title = 'No data for this period',
    this.subtitle = 'Try a different date range or check back later.',
    this.icon = Icons.bar_chart_outlined,
  });

  final String title;
  final String? subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 40,
                color: theme.colorScheme.outlineVariant,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Whether [data] has at least one positive value worth charting.
bool hasReportChartData(Map<String, num> data) {
  return data.values.any((value) => value > 0);
}
