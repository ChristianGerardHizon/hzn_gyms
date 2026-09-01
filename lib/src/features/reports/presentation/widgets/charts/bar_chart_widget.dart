import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A reusable bar chart widget for displaying categorical data.
class BarChartWidget extends StatelessWidget {
  const BarChartWidget({
    super.key,
    required this.data,
    this.title,
    this.height = 200,
    this.barColor,
    this.horizontal = false,
    this.valueFormatter,
  });

  /// Map of labels to values.
  final Map<String, num> data;

  /// Optional title above the chart.
  final String? title;

  /// Height of the chart.
  final double height;

  /// Color of the bars.
  final Color? barColor;

  /// Whether to render as horizontal bars.
  final bool horizontal;

  /// Optional formatter for values.
  final String Function(num)? valueFormatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = barColor ?? theme.colorScheme.primary;

    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(title!, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
            ],
            Expanded(
              child: Center(
                child: Text(
                  'No data available',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final entries = data.entries.toList();
    final maxValue = entries
        .map((e) => e.value)
        .fold<num>(0, (max, value) => value > max ? value : max);
    // fl_chart requires a positive maxY; treat all-zero as empty-scale floor.
    final chartMax = maxValue <= 0 ? 1.0 : maxValue.toDouble() * 1.1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: height,
          child: horizontal
              ? _buildHorizontalChart(context, entries, color, chartMax)
              : _buildVerticalChart(context, entries, color, chartMax),
        ),
      ],
    );
  }

  Widget _buildVerticalChart(
    BuildContext context,
    List<MapEntry<String, num>> entries,
    Color color,
    double maxY,
  ) {
    final theme = Theme.of(context);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = entries[group.x.toInt()].key;
              final value =
                  valueFormatter?.call(rod.toY) ?? _formatNumber(rod.toY);
              return BarTooltipItem(
                '$label\n$value',
                TextStyle(
                  color: theme.colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= entries.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _truncateLabel(entries[index].key),
                    style: theme.textTheme.labelSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatNumber(value),
                  style: theme.textTheme.labelSmall,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateInterval(maxY),
        ),
        barGroups: entries.asMap().entries.map((entry) {
          return BarChartGroupData(
            x: entry.key,
            barRods: [
              BarChartRodData(
                toY: entry.value.value.toDouble(),
                color: color,
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHorizontalChart(
    BuildContext context,
    List<MapEntry<String, num>> entries,
    Color color,
    double maxY,
  ) {
    final theme = Theme.of(context);

    return RotatedBox(
      quarterTurns: 1,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 80,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= entries.length) {
                    return const SizedBox.shrink();
                  }
                  return RotatedBox(
                    quarterTurns: -1,
                    child: Text(
                      entries[index].key,
                      style: theme.textTheme.labelSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          barGroups: entries.asMap().entries.map((entry) {
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.value.toDouble(),
                  color: color,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  String _truncateLabel(String label) {
    if (label.length > 12) {
      return '${label.substring(0, 10)}...';
    }
    return label;
  }

  double _calculateInterval(double maxValue) {
    if (maxValue <= 10) return 2;
    if (maxValue <= 100) return 20;
    if (maxValue <= 1000) return 200;
    return (maxValue / 5).ceilToDouble();
  }

  String _formatNumber(double value) {
    if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return NumberFormat('#,##0').format(value);
  }
}
