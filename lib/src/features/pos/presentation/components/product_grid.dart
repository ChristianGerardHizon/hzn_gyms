import 'package:flutter/material.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/foundation/failure.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../../products/domain/product.dart';
import '../utils/cashier_grid_layout.dart';
import 'cashier_product_card.dart';

class ProductGrid extends ConsumerWidget {
  const ProductGrid({
    super.key,
    this.searchQuery = '',
  });

  final String searchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return FutureBuilder(
      future: _fetchProducts(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return ErrorState.fromError(snapshot.error!, compact: true);
        }

        final result = snapshot.data;
        if (result == null) {
          return const Center(child: Text('No products loaded'));
        }

        return result.fold(
          (failure) => ErrorState.fromError(failure, compact: true),
          (products) {
            if (products.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      searchQuery.isEmpty
                          ? 'No products found'
                          : 'No products match "$searchQuery"',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                return GridView.builder(
                  padding: CashierGridLayout.padding(width),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent:
                        CashierGridLayout.maxCrossAxisExtent(width),
                    childAspectRatio:
                        CashierGridLayout.childAspectRatio(width),
                    crossAxisSpacing: CashierGridLayout.spacing(width),
                    mainAxisSpacing: CashierGridLayout.spacing(width),
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return CashierProductCard(product: products[index]);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Either<Failure, List<Product>>> _fetchProducts(WidgetRef ref) async {
    final repository = ref.read(productRepositoryProvider);

    final Either<Failure, List<Product>> result;
    if (searchQuery.trim().isEmpty) {
      result = await repository.fetchAll();
    } else {
      result = await repository.search(
        searchQuery.trim(),
        fields: ['name', 'description'],
      );
    }

    return result.map(
      (products) => products.where((p) => p.forSale).toList(),
    );
  }
}
