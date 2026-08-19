import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../activity_log/presentation/controllers/todays_activity_logs_controller.dart';
import '../../../activity_log/presentation/widgets/activity_log_expandable_tile.dart';
import 'kpi_breakdown_dialog.dart';

/// Opens today's activity log dialog from the dashboard.
Future<void> showTodaysActivityLogsDialog(BuildContext context) {
  final todayLabel = DateFormat('MMM d, yyyy').format(DateTime.now());
  return showKpiBreakdownDialog(
    context: context,
    title: "Today's Activity",
    subtitle: todayLabel,
    bodyBuilder: (context, ref) => const _TodaysActivityLogsBody(),
  );
}

class _TodaysActivityLogsBody extends ConsumerWidget {
  const _TodaysActivityLogsBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(todaysActivityLogsControllerProvider);
    final controller = ref.read(todaysActivityLogsControllerProvider.notifier);
    final theme = Theme.of(context);

    return logsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 40,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to load data',
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () =>
                    ref.invalidate(todaysActivityLogsControllerProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (state) {
        if (state.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history,
                    size: 48,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.35,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No activity recorded today.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            final metrics = notification.metrics;
            if (!metrics.hasContentDimensions) return false;
            if (metrics.pixels >= metrics.maxScrollExtent - 200 &&
                state.hasMore &&
                !state.isLoadingMore) {
              controller.loadMore();
            }
            return false;
          },
          child: ListView.separated(
            itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index >= state.items.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return ActivityLogExpandableTile(log: state.items[index]);
            },
          ),
        );
      },
    );
  }
}
