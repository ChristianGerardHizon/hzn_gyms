import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/dialog_close_handler.dart';
import '../cart_controller.dart';
import '../controllers/pos_groups_controller.dart';
import 'cashier_body.dart';

/// Opens a walk-in cashier as a dialog without leaving the current route.
///
/// Clears the cart first so the session starts empty. Member stays optional
/// at checkout (leave blank → sale shows as Walk-in).
Future<void> showCashierDialog(BuildContext context, WidgetRef ref) async {
  await ref.read(cartControllerProvider.notifier).clearCart();
  if (!context.mounted) return;

  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (context) => const Dialog(
      insetPadding: EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
      child: _CashierDialogScaffold(),
    ),
  );
}

class _CashierDialogScaffold extends StatelessWidget {
  const _CashierDialogScaffold();

  @override
  Widget build(BuildContext context) {
    return const ScaffoldMessenger(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CashierDialog(),
      ),
    );
  }
}

/// Full cashier UI (products + cart) for walk-in sales from the dashboard.
class CashierDialog extends ConsumerWidget {
  const CashierDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final isMobile = Breakpoints.isMobile(context);
    final posGroupsAsync = ref.watch(posGroupsControllerProvider);
    final groups = posGroupsAsync.value ?? [];
    final hasGroups = groups.isNotEmpty;

    return DialogCloseHandler(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: Material(
          color: theme.colorScheme.surface,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cashier',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Member optional at checkout',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: CashierBody(
                  hasGroups: hasGroups,
                  groups: groups,
                  isMobile: isMobile,
                  compactSearch: true,
                  showCheckIn: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
