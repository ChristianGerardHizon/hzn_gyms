import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/activity_log_filter.dart';
import '../controllers/activity_log_filters_controller.dart';
import '../controllers/activity_logs_controller.dart';

/// Filter bar for the activity log list.
class ActivityLogFiltersBar extends HookConsumerWidget {
  const ActivityLogFiltersBar({super.key});

  static final _dateFormat = DateFormat('MMM d, yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filters = ref.watch(activityLogFiltersControllerProvider);
    final filtersNotifier = ref.read(activityLogFiltersControllerProvider.notifier);
    final searchController = useTextEditingController(text: filters.searchQuery ?? '');

    Future<void> applySearch() {
      filtersNotifier.setSearchQuery(
        searchController.text.trim().isEmpty ? null : searchController.text.trim(),
      );
      return Future.value();
    }

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search summary',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: applySearch,
                ),
              ),
              onSubmitted: (_) => applySearch(),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    final range = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                      initialDateRange: filters.startDate != null && filters.endDate != null
                          ? DateTimeRange(start: filters.startDate!, end: filters.endDate!)
                          : null,
                    );
                    if (range != null) {
                      filtersNotifier.setDateRange(
                        startDate: range.start,
                        endDate: range.end,
                      );
                    }
                  },
                  icon: const Icon(Icons.date_range, size: 18),
                  label: Text(
                    filters.startDate != null && filters.endDate != null
                        ? '${_dateFormat.format(filters.startDate!)} – ${_dateFormat.format(filters.endDate!)}'
                        : 'Last $activityLogDefaultLookbackDays days',
                  ),
                ),
                SizedBox(
                  width: 200,
                  child: DropdownButtonFormField<String?>(
                    key: ValueKey(filters.collection),
                    initialValue: filters.collection,
                    decoration: const InputDecoration(
                      labelText: 'Collection',
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All collections'),
                      ),
                      ...activityLogCollectionOptions.entries.map(
                        (entry) => DropdownMenuItem<String?>(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      ),
                    ],
                    onChanged: filtersNotifier.setCollection,
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  onPressed: () => ref.invalidate(activityLogsControllerProvider),
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Branch filter follows the global branch selector.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
