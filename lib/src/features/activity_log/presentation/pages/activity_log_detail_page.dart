import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/state/error_state.dart';
import '../../domain/activity_log_formatters.dart';
import '../controllers/activity_log_provider.dart';
import '../widgets/activity_log_changes_table.dart';

/// Detail page showing field-level diffs for one activity log entry.
class ActivityLogDetailPage extends ConsumerWidget {
  const ActivityLogDetailPage({super.key, required this.logId});

  final String logId;

  static final _dateFormat = DateFormat('MMM d, yyyy h:mm a');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logAsync = ref.watch(activityLogProvider(logId));
    final theme = Theme.of(context);

    return logAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => ErrorState(
        message: error.toString(),
        onRetry: () => ref.invalidate(activityLogProvider(logId)),
      ),
      data: (log) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              formatActivityLogHeadline(log),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _MetaRow(label: 'Action', value: log.action.label),
            _MetaRow(
              label: 'Collection',
              value: activityLogCollectionLabel(log.collection),
            ),
            _MetaRow(label: 'Record ID', value: log.recordId),
            if (log.actorName != null)
              _MetaRow(label: 'Changed by', value: log.actorName!),
            if (log.branchName != null)
              _MetaRow(label: 'Branch', value: log.branchName!),
            if (log.created != null)
              _MetaRow(label: 'When', value: _dateFormat.format(log.created!)),
            const SizedBox(height: 24),
            Text(
              'Field Changes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            ActivityLogChangesTable(
              collection: log.collection,
              changes: log.changes,
            ),
          ],
        );
      },
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
