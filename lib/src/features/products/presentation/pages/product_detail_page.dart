import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/routing/routes/products.routes.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/form_feedback.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../domain/product_branch_visibility.dart';
import '../../domain/product_tab.dart';
import '../controllers/paginated_products_controller.dart';
import '../controllers/product_provider.dart';
import '../widgets/dialogs/edit_product_dialog.dart';
import '../controllers/product_sales_provider.dart';
import '../widgets/tabs/product_adjustments_tab.dart';
import '../widgets/tabs/product_details_tab.dart';
import '../widgets/tabs/product_overview_tab.dart';
import '../widgets/tabs/product_sales_tab.dart';
import '../widgets/tabs/product_stock_tab.dart';

/// Product detail page with tabs.
class ProductDetailPage extends HookConsumerWidget {
  const ProductDetailPage({
    super.key,
    required this.productId,
    this.initialTab = ProductTab.overview,
  });

  final String productId;
  final ProductTab initialTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productProvider(productId));
    final currentBranchId = ref.watch(currentBranchIdProvider);
    final viewingAllBranches = ref.watch(viewingAllBranchesProvider);
    final isTablet = Breakpoints.isTabletOrLarger(context);
    final mismatchDialogShown = useRef(false);

    // Tab controller
    final tabController = useTabController(
      initialLength: ProductTab.values.length,
      initialIndex: initialTab.index,
    );

    final product = productAsync.asData?.value;
    final productBranchId = product?.branch;
    final isVisible = product == null ||
        isProductVisibleForBranch(
          productBranchId: productBranchId,
          currentBranchId: currentBranchId,
          viewingAllBranches: viewingAllBranches,
        );

    useEffect(() {
      if (product == null) return null;

      // Reset guard when the product becomes visible again (e.g. switch back).
      if (isVisible) {
        mismatchDialogShown.value = false;
        return null;
      }

      if (mismatchDialogShown.value) return null;
      mismatchDialogShown.value = true;

      var cancelled = false;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!context.mounted) return;

        // Re-read providers: branch may have changed before this frame runs.
        final latestProduct =
            ref.read(productProvider(productId)).asData?.value;
        final proceed = shouldProceedWithBranchMismatchRedirect(
          cancelled: cancelled,
          productBranchId: latestProduct?.branch,
          currentBranchId: ref.read(currentBranchIdProvider),
          viewingAllBranches: ref.read(viewingAllBranchesProvider),
        );
        if (!proceed) {
          mismatchDialogShown.value = false;
          return;
        }

        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Product not available'),
            content: const Text(
              'This product is not available in the selected branch.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('OK'),
              ),
            ],
          ),
        );

        if (context.mounted) {
          const ProductsRoute().go(context);
        }
      });

      return () {
        cancelled = true;
        // Allow a later mismatch (or the same one after a brief visible
        // window) to schedule again if this callback never ran.
        mismatchDialogShown.value = false;
      };
    }, [product?.id, productBranchId, currentBranchId, viewingAllBranches]);

    return productAsync.when(
      data: (product) {
        if (product == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Product Not Found'),
              automaticallyImplyLeading: !isTablet,
            ),
            body: const Center(
              child: Text('The requested product could not be found.'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(product.name),
            automaticallyImplyLeading: !isTablet,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  ref.invalidate(productProvider(productId));
                  ref.invalidate(productSalesProvider(productId));
                  showInfoSnackBar(
                    context,
                    message: 'Refreshing...',
                    duration: const Duration(seconds: 1),
                  );
                },
                tooltip: 'Refresh',
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditSheet(context, ref),
              ),
              PopupMenuButton<String>(
                onSelected: (value) =>
                    _handleMenuAction(context, ref, value, product.id),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete_outline),
                      title: Text('Delete'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ],
            bottom: TabBar(
              controller: tabController,
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Details'),
                Tab(text: 'Stock'),
                Tab(text: 'Adjustments'),
                Tab(text: 'Sales'),
              ],
            ),
          ),
          body: TabBarView(
            controller: tabController,
            children: [
              ProductOverviewTab(
                product: product,
                onViewSales: () =>
                    tabController.animateTo(ProductTab.sales.index),
              ),
              ProductDetailsTab(product: product),
              ProductStockTab(product: product),
              ProductAdjustmentsTab(product: product),
              ProductSalesTab(product: product),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
          automaticallyImplyLeading: !isTablet,
        ),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          automaticallyImplyLeading: !isTablet,
        ),
        body: ErrorState.fromError(
          error,
          onRetry: () => ref.invalidate(productProvider(productId)),
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref) {
    showEditProductDialog(context, productId);
  }

  Future<void> _handleMenuAction(
    BuildContext context,
    WidgetRef ref,
    String action,
    String productId,
  ) async {
    if (action == 'delete') {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Product'),
          content: const Text(
            'Are you sure you want to delete this product? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirmed == true && context.mounted) {
        final controller =
            ref.read(paginatedProductsControllerProvider.notifier);
        final success = await controller.deleteProduct(productId);

        if (context.mounted) {
          if (success) {
            showSuccessSnackBar(context,
                message: 'Product deleted successfully');
            // Navigate back to products list
            const ProductsRoute().go(context);
          } else {
            showErrorSnackBar(context, message: 'Failed to delete product');
          }
        }
      }
    }
  }
}
