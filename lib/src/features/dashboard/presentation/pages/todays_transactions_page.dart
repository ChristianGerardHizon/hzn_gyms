import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/state/error_state.dart';
import '../controllers/todays_sales_controller.dart';
import '../widgets/sale_quick_view_dialog.dart';
import '../widgets/today_sale_list_tile.dart';

/// Full-screen list of all sales made today for the current branch.
class TodaysTransactionsPage extends ConsumerWidget {
  const TodaysTransactionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(todaySalesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Transactions"),
      ),
      body: salesAsync.when(
        data: (sales) {
          if (sales.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No transactions today',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(todaySalesProvider);
              await ref.read(todaySalesProvider.future);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: sales.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final sale = sales[index];
                return TodaySaleListTile(
                  sale: sale,
                  onTap: () => showSaleQuickViewDialog(
                    context,
                    saleId: sale.id,
                    fallbackSale: sale,
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => ErrorState.fromError(
          error,
          onRetry: () => ref.invalidate(todaySalesProvider),
        ),
      ),
    );
  }
}
