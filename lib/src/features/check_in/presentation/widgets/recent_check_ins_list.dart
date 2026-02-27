import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/check_in_controller.dart';
import '../../domain/check_in.dart';

/// Widget displaying today's recent check-ins.
class RecentCheckInsList extends ConsumerWidget {
  const RecentCheckInsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkInsAsync = ref.watch(checkInControllerProvider);
    final theme = Theme.of(context);
    final timeFormat = DateFormat('hh:mm a');

    return checkInsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 8),
            Text('Error: $error'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () =>
                  ref.read(checkInControllerProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (checkIns) {
        if (checkIns.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.how_to_reg_outlined,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No check-ins today',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () =>
              ref.read(checkInControllerProvider.notifier).refresh(),
          child: ListView.separated(
            itemCount: checkIns.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final checkIn = checkIns[index];
              return _CheckInListTile(
                checkIn: checkIn,
                timeFormat: timeFormat,
              );
            },
          ),
        );
      },
    );
  }
}

class _CheckInListTile extends StatelessWidget {
  const _CheckInListTile({
    required this.checkIn,
    required this.timeFormat,
  });

  final CheckIn checkIn;
  final DateFormat timeFormat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green.withValues(alpha: 0.15),
        child: const Icon(
          Icons.how_to_reg,
          color: Colors.green,
          size: 20,
        ),
      ),
      title: Text(checkIn.memberName ?? 'Unknown Member'),
      subtitle: Text(
        '${timeFormat.format(checkIn.checkInTime)} - ${checkIn.method.displayName}',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
