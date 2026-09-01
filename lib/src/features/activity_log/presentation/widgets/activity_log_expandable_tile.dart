import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/activity_log.dart';
import '../../domain/activity_log_action.dart';
import '../../domain/activity_log_formatters.dart';
import 'activity_log_changes_table.dart';

/// Expandable row: descriptive headline when collapsed, field diffs when open.
class ActivityLogExpandableTile extends StatelessWidget {
  const ActivityLogExpandableTile({super.key, required this.log});

  final ActivityLog log;

  static final _dateFormat = DateFormat('MMM d, yyyy h:mm a');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = formatActivityLogChangePreview(log);

    return ExpansionTile(
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.secondaryContainer,
        child: Icon(
          _iconForAction(log.action),
          color: theme.colorScheme.onSecondaryContainer,
          size: 20,
        ),
      ),
      title: Text(
        formatActivityLogHeadline(log),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (preview != null) ...[
            const SizedBox(height: 4),
            Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          if (log.created != null) ...[
            const SizedBox(height: 2),
            Text(
              _dateFormat.format(log.created!),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ActivityLogChangesTable(
            collection: log.collection,
            changes: log.changes,
          ),
        ),
      ],
    );
  }

  IconData _iconForAction(ActivityLogAction action) => switch (action) {
    ActivityLogAction.create => Icons.add_circle_outline,
    ActivityLogAction.update => Icons.edit_outlined,
    ActivityLogAction.delete => Icons.delete_outline,
  };
}
