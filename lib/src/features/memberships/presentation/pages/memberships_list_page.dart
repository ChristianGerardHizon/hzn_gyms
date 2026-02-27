import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../controllers/memberships_controller.dart';
import '../widgets/membership_list_panel.dart';

/// Memberships list page for mobile view.
class MembershipsListPage extends ConsumerWidget {
  const MembershipsListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membershipsAsync = ref.watch(membershipsControllerProvider);

    return membershipsAsync.when(
      data: (memberships) => MembershipListPanel(memberships: memberships),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('Error loading memberships: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(membershipsControllerProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
