import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A reusable pie chart widget for displaying distribution data.
class PieChartWidget extends StatefulWidget {
  const PieChartWidget({
    super.key,
    required this.data,
    this.title,
    this.height = 200,
    this.colors,
    this.showLegend = true,
    this.centerRadius = 40,
  });

  /// Map of labels to values.
  final Map<String, num> data;

  /// Optional title above the chart.
  final String? title;

  /// Height of the chart.
  final double height;

  /// Optional list of colors for sections.
  final List<Color>? colors;

  /// Whether to show the legend.
  final bool showLegend;

  /// Radius of the center hole.
  final double centerRadius;

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  int touchedIndex = -1;

  static const List<Color> _defaultColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFFC107), // Amber
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF3F51B5), // Indigo
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.data.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.title != null) ...[
              Text(widget.title!, style: theme.textTheme.titleSmall),
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

    final entries = widget.data.entries.toList();
    final total = entries.fold<num>(0, (sum, e) => sum + e.value);
    final colors = widget.colors ?? _defaultColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Text(widget.title!, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: widget.height,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            touchedIndex = -1;
                            return;
                          }
                          touchedIndex = pieTouchResponse
                              .touchedSection!
                              .touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: widget.centerRadius,
                    sections: entries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final isTouched = index == touchedIndex;
                      final value = entry.value.value;
                      final percentage = total > 0
                          ? (value / total * 100)
                          : 0.0;
                      final color = colors[index % colors.length];

                      return PieChartSectionData(
                        color: color,
                        value: value.toDouble(),
                        title: '${percentage.toStringAsFixed(1)}%',
                        radius: isTouched ? 60 : 50,
                        titleStyle: TextStyle(
                          fontSize: isTouched ? 14 : 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: const [
                            Shadow(color: Colors.black26, blurRadius: 2),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              if (widget.showLegend) ...[
                const SizedBox(width: 16),
                Expanded(child: _buildLegend(entries, colors, total)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegend(
    List<MapEntry<String, num>> entries,
    List<Color> colors,
    num total,
  ) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: entries.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value.key;
          final value = entry.value.value;
          final color = colors[index % colors.length];
          final isTouched = index == touchedIndex;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                    border: isTouched
                        ? Border.all(color: theme.colorScheme.outline, width: 2)
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: isTouched ? FontWeight.bold : null,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  value.toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: isTouched ? FontWeight.bold : null,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
