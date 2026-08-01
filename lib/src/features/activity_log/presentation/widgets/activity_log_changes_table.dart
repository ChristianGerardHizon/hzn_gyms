import 'package:flutter/material.dart';

import '../../domain/activity_log_change.dart';
import '../../domain/activity_log_formatters.dart';

/// Table showing field-level before/after values for an activity log entry.
class ActivityLogChangesTable extends StatelessWidget {
  const ActivityLogChangesTable({
    super.key,
    required this.collection,
    required this.changes,
  });

  final String collection;
  final List<ActivityLogChange> changes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sorted = sortedActivityLogChanges(changes);

    if (sorted.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No field changes recorded.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(
          theme.colorScheme.surfaceContainerHighest,
        ),
        columns: const [
          DataColumn(label: Text('Field')),
          DataColumn(label: Text('Before')),
          DataColumn(label: Text('After')),
        ],
        rows: sorted
            .map(
              (change) => DataRow(
                cells: [
                  DataCell(Text(activityLogFieldLabel(collection, change.field))),
                  DataCell(Text(formatActivityLogValue(change.oldValue))),
                  DataCell(Text(formatActivityLogValue(change.newValue))),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
