import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../domain/check_in.dart';
import '../controllers/check_in_records_controller.dart';
import '../controllers/check_in_records_date_controller.dart';

/// Check-in history for a selected calendar date.
class CheckInRecordsPage extends ConsumerWidget {
  const CheckInRecordsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMobile = Breakpoints.isMobile(context);
    final horizontalPad = isMobile ? 16.0 : 24.0;
    final selectedDate = ref.watch(checkInRecordsDateControllerProvider);
    final checkInsAsync = ref.watch(checkInRecordsControllerProvider);
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    final isToday = selectedDate == toLocalDateOnly(DateTime.now());

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPad,
              isMobile ? 12 : 20,
              horizontalPad,
              isMobile ? 8 : 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Check-In Records',
                    style:
                        (isMobile
                                ? theme.textTheme.titleLarge
                                : theme.textTheme.headlineMedium)
                            ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                checkInsAsync.whenOrNull(
                      data: (checkIns) => Text(
                        '${checkIns.length} check-in${checkIns.length == 1 ? '' : 's'}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ) ??
                    const SizedBox.shrink(),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPad),
            child: _DateSelector(
              selectedDate: selectedDate,
              dateFormat: dateFormat,
              isToday: isToday,
              isMobile: isMobile,
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          Expanded(
            child: checkInsAsync.when(
              skipLoadingOnReload: true,
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorState.fromError(
                error,
                onRetry: () => ref
                    .read(checkInRecordsControllerProvider.notifier)
                    .refresh(),
              ),
              data: (checkIns) {
                if (checkIns.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isToday
                              ? 'No check-ins today'
                              : 'No check-ins on ${dateFormat.format(selectedDate)}',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(checkInRecordsControllerProvider.notifier)
                      .refresh(),
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 0 : horizontalPad,
                      vertical: 8,
                    ),
                    itemCount: checkIns.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final checkIn = checkIns[index];
                      return _CheckInRecordTile(
                        checkIn: checkIn,
                        timeFormat: timeFormat,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSelector extends ConsumerWidget {
  const _DateSelector({
    required this.selectedDate,
    required this.dateFormat,
    required this.isToday,
    required this.isMobile,
  });

  final DateTime selectedDate;
  final DateFormat dateFormat;
  final bool isToday;
  final bool isMobile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateNotifier = ref.read(
      checkInRecordsDateControllerProvider.notifier,
    );
    final canGoNext = selectedDate.isBefore(toLocalDateOnly(DateTime.now()));

    Future<void> pickDate() async {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2020),
        lastDate: toLocalDateOnly(DateTime.now()),
      );
      if (picked != null) {
        dateNotifier.setDate(picked);
      }
    }

    return Row(
      children: [
        IconButton(
          tooltip: 'Previous day',
          onPressed: dateNotifier.previousDay,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: pickDate,
            icon: const Icon(Icons.calendar_today, size: 18),
            label: Text(
              dateFormat.format(selectedDate),
              overflow: TextOverflow.ellipsis,
            ),
            style: OutlinedButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 12 : 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next day',
          onPressed: canGoNext ? dateNotifier.nextDay : null,
          icon: const Icon(Icons.chevron_right),
        ),
        if (!isToday)
          TextButton(
            onPressed: dateNotifier.goToToday,
            child: const Text('Today'),
          ),
      ],
    );
  }
}

class _CheckInRecordTile extends StatelessWidget {
  const _CheckInRecordTile({required this.checkIn, required this.timeFormat});

  final CheckIn checkIn;
  final DateFormat timeFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green.withValues(alpha: 0.15),
        child: const Icon(Icons.how_to_reg, color: Colors.green, size: 20),
      ),
      title: Text(checkIn.memberName ?? 'Unknown Member'),
      subtitle: Text(
        '${timeFormat.format(checkIn.checkInTime)} · ${checkIn.method.displayName}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
