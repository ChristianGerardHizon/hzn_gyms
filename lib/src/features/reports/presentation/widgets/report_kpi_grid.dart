import 'package:flutter/material.dart';

/// Arranges children into rows of [crossAxisCount] items with uniform spacing.
///
/// Incomplete rows are padded with invisible placeholders to maintain alignment.
class ReportKpiGrid extends StatelessWidget {
  const ReportKpiGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 4,
    this.spacing = 12.0,
  });

  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;

  /// Breakpoint below which cards stack into a single column.
  static const double _mobileBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < _mobileBreakpoint;
        if (isMobile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: spacing,
            children: children,
          );
        }
        return _buildGrid();
      },
    );
  }

  Widget _buildGrid() {
    final rows = <Widget>[];

    for (var i = 0; i < children.length; i += crossAxisCount) {
      final end = (i + crossAxisCount).clamp(0, children.length);
      final rowChildren = children.sublist(i, end);
      final paddingCount = crossAxisCount - rowChildren.length;

      final rowWidgets = <Widget>[];
      for (var j = 0; j < rowChildren.length; j++) {
        if (j > 0) rowWidgets.add(SizedBox(width: spacing));
        rowWidgets.add(Expanded(child: rowChildren[j]));
      }

      // Pad with invisible placeholders
      for (var j = 0; j < paddingCount; j++) {
        rowWidgets.add(SizedBox(width: spacing));
        rowWidgets.add(const Expanded(child: SizedBox.shrink()));
      }

      if (rows.isNotEmpty) rows.add(SizedBox(height: spacing));
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: rowWidgets,
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rows,
    );
  }
}
