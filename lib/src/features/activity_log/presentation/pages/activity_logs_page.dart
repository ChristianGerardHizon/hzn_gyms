import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/routes/system.routes.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../controllers/activity_logs_controller.dart';
import '../widgets/activity_log_filters_bar.dart';
import '../widgets/activity_log_list_tile.dart';

/// Activity log summary list page.
class ActivityLogsPage extends ConsumerWidget {
  const ActivityLogsPage({
    super.key,
    this.selectedId,
    this.onSelected,
  });

  /// Currently selected log id (tablet split view).
  final String? selectedId;

  /// Called when a log row is tapped (tablet split view).
  final ValueChanged<String>? onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(activityLogsControllerProvider);
    final controller = ref.read(activityLogsControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ActivityLogFiltersBar(),
        Expanded(
          child: logsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => ErrorState(
              message: error.toString(),
              onRetry: () => ref.invalidate(activityLogsControllerProvider),
            ),
            data: (state) {
              if (state.isEmpty) {
                return const Center(child: Text('No activity recorded yet.'));
              }

              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.pixels >=
                          notification.metrics.maxScrollExtent - 200 &&
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

                    final log = state.items[index];
                    return ActivityLogListTile(
                      log: log,
                      selected: log.id == selectedId,
                      onTap: () {
                        if (onSelected != null) {
                          onSelected!(log.id);
                        } else {
                          ActivityLogDetailRoute(id: log.id).push(context);
                        }
                      },
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
