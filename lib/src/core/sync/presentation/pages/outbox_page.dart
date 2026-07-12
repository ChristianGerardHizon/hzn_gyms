import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../widgets/state/error_state.dart';
import '../../outbox_sync_worker.dart';
import '../../sync_status.dart';

/// Full-page view of pending/failed outbox queue entries.
class OutboxPage extends ConsumerWidget {
  const OutboxPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entriesAsync = ref.watch(outboxPendingEntriesProvider);
    final pendingCount = ref.watch(outboxPendingCountProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Outbox'),
        actions: [
          if (pendingCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Chip(
                  label: Text('$pendingCount pending'),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ),
          IconButton(
            tooltip: 'Retry sync',
            onPressed: () async {
              await ref.read(outboxSyncWorkerProvider.notifier).drain();
              ref.invalidate(outboxPendingEntriesProvider);
            },
            icon: const Icon(Icons.sync),
          ),
        ],
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState.fromError(
          error,
          onRetry: () => ref.invalidate(outboxPendingEntriesProvider),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_done_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Queue is empty',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Offline changes will appear here until synced',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(outboxPendingEntriesProvider);
              await ref.read(outboxPendingEntriesProvider.future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: entries.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _OutboxEntryTile(entry: entries[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _OutboxEntryTile extends StatelessWidget {
  const _OutboxEntryTile({required this.entry});

  final OutboxPendingItem entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd().add_jm();

    return ExpansionTile(
      leading: _statusAvatar(theme, entry.status),
      title: Text(entry.displayTitle),
      subtitle: Text(
        '${entry.status} · ${dateFormat.format(entry.createdAt.toLocal())}'
        '${entry.hasAttachment ? ' · photo' : ''}',
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        _DetailRow(label: 'Status', value: entry.status),
        _DetailRow(label: 'Attempts', value: '${entry.attempts}'),
        _DetailRow(label: 'Record ID', value: entry.clientRecordId),
        _DetailRow(label: 'Outbox ID', value: entry.id),
        if (entry.dependsOnId != null)
          _DetailRow(label: 'Depends on', value: entry.dependsOnId!),
        if (entry.hasAttachment)
          const _DetailRow(label: 'Attachment', value: 'Photo queued'),
        if (entry.lastError != null && entry.lastError!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Last error',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              entry.lastError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ],
        if (entry.payloadJson != null && entry.payloadJson!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Payload', style: theme.textTheme.labelMedium),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SelectableText(
              _prettyJson(entry.payloadJson!),
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _statusAvatar(ThemeData theme, String status) {
    final (icon, color) = switch (status) {
      'pending' => (Icons.schedule, Colors.orange),
      'failed' => (Icons.error_outline, theme.colorScheme.error),
      'conflict' => (Icons.warning_amber, Colors.amber.shade800),
      _ => (Icons.cloud_upload_outlined, theme.colorScheme.primary),
    };
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.15),
      child: Icon(icon, color: color, size: 20),
    );
  }

  String _prettyJson(String raw) {
    try {
      final decoded = jsonDecode(raw);
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(decoded);
    } catch (_) {
      return raw;
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(value, style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
