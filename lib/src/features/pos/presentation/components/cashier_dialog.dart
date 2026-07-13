import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/dialog_close_handler.dart';
import '../../domain/pos_group.dart';
import '../cart_controller.dart';
import '../controllers/pos_groups_controller.dart';
import 'cart_view.dart';
import 'cashier_search_dropdown.dart';
import 'grouped_cashier_view.dart';
import 'product_grid.dart';

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
                child: isMobile
                    ? _MobileCashierBody(
                        hasGroups: hasGroups,
                        groups: groups,
                      )
                    : _DesktopCashierBody(
                        hasGroups: hasGroups,
                        groups: groups,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DesktopCashierBody extends StatelessWidget {
  const _DesktopCashierBody({
    required this.hasGroups,
    required this.groups,
  });

  final bool hasGroups;
  final List<PosGroup> groups;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          flex: 6,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 12, 12, 0),
                child: CashierSearchDropdown(),
              ),
              const SizedBox(height: 12),
              if (hasGroups)
                Expanded(child: GroupedCashierView(groups: groups))
              else ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Products',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                const Expanded(child: ProductGrid()),
              ],
            ],
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          flex: 4,
          child: ColoredBox(
            color: theme.colorScheme.surfaceContainerLowest,
            child: const CartView(),
          ),
        ),
      ],
    );
  }
}

class _MobileCashierBody extends StatelessWidget {
  const _MobileCashierBody({
    required this.hasGroups,
    required this.groups,
  });

  final bool hasGroups;
  final List<PosGroup> groups;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(8),
          child: CashierSearchDropdown(isDense: true),
        ),
        Expanded(
          flex: 3,
          child: hasGroups
              ? GroupedCashierView(groups: groups)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Products',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    const Expanded(child: ProductGrid()),
                  ],
                ),
        ),
        const Divider(height: 1),
        const Expanded(
          flex: 2,
          child: CartView(),
        ),
      ],
    );
  }
}
