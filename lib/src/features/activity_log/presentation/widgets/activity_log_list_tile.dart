import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/activity_log.dart';
import '../../domain/activity_log_action.dart';
import '../../domain/activity_log_formatters.dart';

/// List tile showing an activity log summary row.
class ActivityLogListTile extends StatelessWidget {
  const ActivityLogListTile({
    super.key,
    required this.log,
    required this.onTap,
    this.selected = false,
  });

  final ActivityLog log;
  final VoidCallback onTap;
  final bool selected;

  static final _dateFormat = DateFormat('MMM d, yyyy h:mm a');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final preview = formatActivityLogChangePreview(log);

    return ListTile(
      selected: selected,
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
      trailing: Text(
        activityLogCollectionLabel(log.collection),
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
      onTap: onTap,
    );
  }

  IconData _iconForAction(ActivityLogAction action) => switch (action) {
    ActivityLogAction.create => Icons.add_circle_outline,
    ActivityLogAction.update => Icons.edit_outlined,
    ActivityLogAction.delete => Icons.delete_outline,
  };
}
