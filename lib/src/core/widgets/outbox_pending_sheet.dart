import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../routing/org_scoped_navigation.dart';
import '../routing/routes/outbox.routes.dart';
import '../sync/outbox_sync_worker.dart';

/// Tappable pending count badge for the app shell.
class OutboxPendingBadge extends ConsumerWidget {
  const OutboxPendingBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(outboxPendingCountProvider);
    final theme = Theme.of(context);

    return pendingAsync.when(
      data: (count) {
        if (count == 0) return const SizedBox.shrink();
        return InkWell(
          onTap: () => const OutboxRoute().goScoped(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_upload_outlined,
                  size: 12,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '$count pending',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
