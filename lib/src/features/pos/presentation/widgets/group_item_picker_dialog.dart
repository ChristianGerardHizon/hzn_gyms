import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../../../core/utils/currency_format.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../../../products/domain/product.dart';
import '../../domain/pos_group.dart';
import '../controllers/pos_groups_controller.dart';

/// Shows a dialog to pick products to add to a group.
Future<void> showGroupItemPickerDialog(
  BuildContext context, {
  required PosGroup group,
}) async {
  await showDialog(
    context: context,
    builder: (context) => _GroupItemPickerDialog(group: group),
  );
}

class _GroupItemPickerDialog extends HookConsumerWidget {
  const _GroupItemPickerDialog({required this.group});

  final PosGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final searchQuery = useState('');

    useEffect(() {
      void listener() => searchQuery.value = searchController.text;
      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    // Track existing item IDs to show which are already added
    final existingProductIds =
        group.items.where((i) => i.isProduct).map((i) => i.productId).toSet();

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add to "${group.name}"',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Search products...',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => searchController.clear(),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Product list
            Expanded(
              child: _ProductPickerList(
                searchQuery: searchQuery.value,
                existingIds: existingProductIds,
                groupId: group.id,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductPickerList extends ConsumerWidget {
  const _ProductPickerList({
    required this.searchQuery,
    required this.existingIds,
    required this.groupId,
  });

  final String searchQuery;
  final Set<String?> existingIds;
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: _fetchProducts(ref),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = snapshot.data ?? [];

        if (products.isEmpty) {
          return Center(
            child: Text(
              searchQuery.isEmpty
                  ? 'No products available'
                  : 'No products match "$searchQuery"',
            ),
          );
        }

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            final isAdded = existingIds.contains(product.id);

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isAdded
                    ? Theme.of(context).colorScheme.primaryContainer
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  isAdded ? Icons.check : Icons.inventory_2,
                  color: isAdded
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : null,
                ),
              ),
              title: Text(product.name),
              subtitle: Text(
                product.isVariablePrice
                    ? 'Variable price'
                    : product.price.toCurrency(),
              ),
              trailing: isAdded
                  ? const Chip(label: Text('Added'))
                  : IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: () async {
                        await ref
                            .read(posGroupsControllerProvider.notifier)
                            .addProductToGroup(groupId, product.id);
                      },
                    ),
            );
          },
        );
      },
    );
  }

  Future<List<Product>> _fetchProducts(WidgetRef ref) async {
    final repository = ref.read(productRepositoryProvider);
    final result = searchQuery.trim().isEmpty
        ? await repository.fetchAll()
        : await repository.search(searchQuery.trim(),
            fields: ['name', 'description']);

    return result.fold(
      (failure) => [],
      (products) => products.where((p) => p.forSale && !p.isDeleted).toList(),
    );
  }
}
