import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A reusable line chart widget for displaying trends over time.
class LineChartWidget extends StatelessWidget {
  const LineChartWidget({
    super.key,
    required this.spots,
    required this.xLabels,
    this.title,
    this.height = 200,
    this.lineColor,
    this.showDots = false,
    this.yAxisFormatter,
  });

  /// The data points for the line chart.
  final List<FlSpot> spots;

  /// Labels for the x-axis.
  final List<String> xLabels;

  /// Optional title above the chart.
  final String? title;

  /// Height of the chart.
  final double height;

  /// Color of the line.
  final Color? lineColor;

  /// Whether to show dots at data points.
  final bool showDots;

  /// Optional formatter for y-axis values.
  final String Function(double)? yAxisFormatter;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = lineColor ?? theme.colorScheme.primary;

    if (spots.isEmpty) {
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: _calculateYInterval(),
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                    strokeWidth: 1,
                  );
                },
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
                    reservedSize: 30,
                    interval: _calculateXInterval(),
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= xLabels.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          xLabels[index],
                          style: theme.textTheme.labelSmall,
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 50,
                    interval: _calculateYInterval(),
                    getTitlesWidget: (value, meta) {
                      final formatted =
                          yAxisFormatter?.call(value) ?? _formatNumber(value);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Text(
                          formatted,
                          style: theme.textTheme.labelSmall,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: color,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: FlDotData(show: showDots),
                  belowBarData: BarAreaData(
                    show: true,
                    color: color.withValues(alpha: 0.1),
                  ),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final label = spot.x.toInt() < xLabels.length
                          ? xLabels[spot.x.toInt()]
                          : '';
                      final value =
                          yAxisFormatter?.call(spot.y) ?? _formatNumber(spot.y);
                      return LineTooltipItem(
                        '$label\n$value',
                        TextStyle(
                          color: theme.colorScheme.onInverseSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _calculateXInterval() {
    if (xLabels.length <= 7) return 1;
    return (xLabels.length / 5).ceilToDouble();
  }

  double _calculateYInterval() {
    if (spots.isEmpty) return 1;
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    if (maxY <= 10) return 2;
    if (maxY <= 100) return 20;
    if (maxY <= 1000) return 200;
    return (maxY / 5).ceilToDouble();
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
