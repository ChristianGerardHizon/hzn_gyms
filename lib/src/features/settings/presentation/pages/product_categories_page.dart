import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/widgets/state/error_state.dart';
import '../../../products/domain/product_category.dart';
import '../controllers/product_categories_controller.dart';
import '../widgets/dialogs/product_category_form_dialog.dart';

/// Product categories list page with CRUD operations.
class ProductCategoriesPage extends ConsumerWidget {
  const ProductCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(productCategoriesControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Categories'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormSheet(context),
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState.fromError(
          error,
          onRetry: () => ref
              .read(productCategoriesControllerProvider.notifier)
              .refresh(),
        ),
        data: (categories) {
          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No categories yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to add a category',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          }

          // Build hierarchical display
          final rootCategories =
              categories.where((c) => !c.hasParent).toList();
          final childCategories =
              categories.where((c) => c.hasParent).toList();

          return RefreshIndicator(
            onRefresh: () => ref
                .read(productCategoriesControllerProvider.notifier)
                .refresh(),
            child: ListView.builder(
              itemCount: rootCategories.length,
              itemBuilder: (context, index) {
                final category = rootCategories[index];
                final children = childCategories
                    .where((c) => c.parentId == category.id)
                    .toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryTile(
                      category: category,
                      onEdit: () =>
                          _showFormSheet(context, category: category),
                      onDelete: () =>
                          _showDeleteConfirmation(context, ref, category),
                    ),
                    // Show children with indentation
                    ...children.map((child) => Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: _CategoryTile(
                            category: child,
                            isChild: true,
                            onEdit: () =>
                                _showFormSheet(context, category: child),
                            onDelete: () =>
                                _showDeleteConfirmation(context, ref, child),
                          ),
                        )),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showFormSheet(BuildContext context, {ProductCategory? category}) {
    showProductCategoryFormDialog(context, category: category);
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    ProductCategory category,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref
                  .read(productCategoriesControllerProvider.notifier)
                  .deleteCategory(category.id);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.onEdit,
    required this.onDelete,
    this.isChild = false,
  });

  final ProductCategory category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isChild;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isChild
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.primaryContainer,
        child: Icon(
          isChild ? Icons.subdirectory_arrow_right : Icons.inventory_2_outlined,
          color: isChild
              ? theme.colorScheme.onSecondaryContainer
              : theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(category.name),
      subtitle: category.hasParent && category.parentName != null
          ? Text('Parent: ${category.parentName}')
          : null,
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          switch (value) {
            case 'edit':
              onEdit();
              break;
            case 'delete':
              onDelete();
              break;
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'edit',
            child: ListTile(
              leading: Icon(Icons.edit_outlined),
              title: Text('Edit'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const PopupMenuItem(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete_outlined),
              title: Text('Delete'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
      onTap: onEdit,
    );
  }
}
