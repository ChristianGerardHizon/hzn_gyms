import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/routes/sales_history.routes.dart';
import '../controllers/paginated_sales_controller.dart';
import '../widgets/sale_list_panel.dart';

/// Sales list page for mobile view.
///
/// Shows the sales list panel and navigates to detail on tap.
class SalesListPage extends ConsumerWidget {
  const SalesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paginatedAsync = ref.watch(paginatedSalesControllerProvider);

    return paginatedAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 16),
              Text('Error: ${error.toString()}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref
                    .read(paginatedSalesControllerProvider.notifier)
                    .refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (paginatedState) => SaleListPanel(
        paginatedState: paginatedState,
        selectedId: null,
        onSaleTap: (sale) {
          SaleDetailRoute(id: sale.id).push(context);
        },
        onRefresh: () =>
            ref.read(paginatedSalesControllerProvider.notifier).refresh(),
        onLoadMore: () =>
            ref.read(paginatedSalesControllerProvider.notifier).loadMore(),
      ),
    );
  }
}
