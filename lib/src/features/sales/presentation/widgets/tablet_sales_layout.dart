import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/org_scoped_navigation.dart';
import '../../../../core/routing/routes/sales_history.routes.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../controllers/paginated_sales_controller.dart';
import 'empty_sale_detail_state.dart';
import 'sale_list_panel.dart';

/// Two-pane tablet layout for sales.
///
/// Left pane: Sale list with search
/// Right pane: Sale detail from router or empty state
class TabletSalesLayout extends ConsumerWidget {
  const TabletSalesLayout({
    super.key,
    required this.detailChild,
  });

  /// The detail panel content from the router.
  final Widget detailChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesAsync = ref.watch(paginatedSalesControllerProvider);
    final salesController =
        ref.read(paginatedSalesControllerProvider.notifier);

    // Get selected sale ID from current route
    final routerState = GoRouterState.of(context);
    final selectedSaleId = routerState.pathParameters['id'];

    return salesAsync.when(
      skipLoadingOnReload: true,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorState.fromError(
        error,
        onRetry: () => salesController.refresh(),
      ),
      data: (paginatedState) => Row(
        children: [
          // List panel
          SizedBox(
            width: 320,
            child: SaleListPanel(
              paginatedState: paginatedState,
              selectedId: selectedSaleId,
              onSaleTap: (sale) {
                // Navigate using the route - this updates the URL and detail panel
                SaleDetailRoute(id: sale.id).goScoped(context);
              },
              onRefresh: () => salesController.refresh(),
              onLoadMore: () => salesController.loadMore(),
            ),
          ),
          const VerticalDivider(width: 1),
          // Detail panel from router
          Expanded(
            child: selectedSaleId != null
                ? detailChild
                : const EmptySaleDetailState(),
          ),
        ],
      ),
    );
  }
}
