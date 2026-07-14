import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../sync/outbox_sync_worker.dart';

/// Red notification-style count badge for the Outbox nav destination.
///
/// Shows only when the outbox queue has one or more items.
class OutboxQueueBadge extends ConsumerWidget {
  const OutboxQueueBadge({
    super.key,
    required this.child,
    this.alignment = AlignmentDirectional.topEnd,
  });

  final Widget child;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(outboxPendingCountProvider).value ?? 0;
    return Badge(
      isLabelVisible: count > 0,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      alignment: alignment,
      offset: const Offset(4, -4),
      label: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          height: 1,
        ),
      ),
      child: child,
    );
  }
}
