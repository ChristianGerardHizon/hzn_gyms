import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/i18n/strings.g.dart';
import '../../../../core/routing/org_scoped_navigation.dart';
import '../../../../core/routing/routes/system.routes.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../../products/domain/product_category.dart';
import '../controllers/product_categories_controller.dart';

/// List panel for product categories in tablet two-pane layout.
class ProductCategoryListPanel extends HookConsumerWidget {
  const ProductCategoryListPanel({
    super.key,
    this.selectedId,
  });

  /// Currently selected category ID for highlighting.
  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);
    final categoriesAsync = ref.watch(productCategoriesControllerProvider);
    final controller = ref.read(productCategoriesControllerProvider.notifier);

    // Search state
    final searchController = useTextEditingController();
    final searchText = useState('');

    final query = searchText.value.trim();
    final isSearchActive = query.isNotEmpty;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'product_category_fab',
        onPressed: () =>
            const ProductCategoryDetailRoute(id: 'new').goScoped(context),
        child: const Icon(Icons.add),
      ),
      body: categoriesAsync.when(
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => ErrorState.fromError(
          error,
          compact: true,
          onRetry: () => controller.refresh(),
        ),
        data: (categories) {
          final filteredCategories = isSearchActive
              ? _filterCategories(categories, query)
              : categories;
          final totalCount = filteredCategories.length;

          // Build hierarchical display
          final rootCategories =
              filteredCategories.where((c) => !c.hasParent).toList();
          final childCategories =
              filteredCategories.where((c) => c.hasParent).toList();

          return Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Row(
                  children: [
                    Text('Categories', style: theme.textTheme.titleLarge),
                    const Spacer(),
                    Text(
                      '$totalCount total',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // Search
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: _SearchInput(
                  controller: searchController,
                  onTextChanged: (text) => searchText.value = text,
                  searchText: searchText.value,
                  hintText: '${t.common.search}...',
                ),
              ),

              // List
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.refresh(),
                  child: filteredCategories.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 80),
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 80,
                              color: theme.colorScheme.outlineVariant,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              isSearchActive
                                  ? 'No categories match "$query"'
                                  : 'No categories yet',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isSearchActive
                                  ? 'Try a different search term'
                                  : 'Tap + to add a category',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: rootCategories.length,
                          itemBuilder: (context, index) {
                            final category = rootCategories[index];
                            final children = childCategories
                                .where((c) => c.parentId == category.id)
                                .toList();

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _CategoryListTile(
                                  category: category,
                                  isSelected: category.id == selectedId,
                                  isChild: false,
                                  onTap: () =>
                                      ProductCategoryDetailRoute(id: category.id)
                                          .go(context),
                                ),
                                // Show children with indentation
                                ...children.map((child) => Padding(
                                      padding: const EdgeInsets.only(left: 24),
                                      child: _CategoryListTile(
                                        category: child,
                                        isSelected: child.id == selectedId,
                                        isChild: true,
                                        onTap: () => ProductCategoryDetailRoute(
                                                id: child.id)
                                            .go(context),
                                      ),
                                    )),
                              ],
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryListTile extends StatelessWidget {
  const _CategoryListTile({
    required this.category,
    required this.isSelected,
    required this.isChild,
    required this.onTap,
  });

  final ProductCategory category;
  final bool isSelected;
  final bool isChild;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      selected: isSelected,
      selectedTileColor: theme.colorScheme.primaryContainer.withValues(
        alpha: 0.3,
      ),
      leading: CircleAvatar(
        backgroundColor: isSelected
            ? theme.colorScheme.primary
            : isChild
                ? theme.colorScheme.secondaryContainer
                : theme.colorScheme.primaryContainer,
        child: Icon(
          isChild ? Icons.subdirectory_arrow_right : Icons.inventory_2_outlined,
          color: isSelected
              ? theme.colorScheme.onPrimary
              : isChild
                  ? theme.colorScheme.onSecondaryContainer
                  : theme.colorScheme.onPrimaryContainer,
        ),
      ),
      title: Text(category.name),
      subtitle: category.hasParent && category.parentName != null
          ? Text('Parent: ${category.parentName}')
          : null,
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.onTextChanged,
    required this.searchText,
    required this.hintText,
  });

  final TextEditingController controller;
  final ValueChanged<String> onTextChanged;
  final String searchText;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onTextChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchText.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        onTextChanged('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
              filled: true,
            ),
          ),
        ),
      ],
    );
  }
}

List<ProductCategory> _filterCategories(
    List<ProductCategory> categories, String query) {
  final normalizedQuery = query.trim().toLowerCase();
  if (normalizedQuery.isEmpty) {
    return categories;
  }

  return categories.where((c) {
    final nameMatch = c.name.toLowerCase().contains(normalizedQuery);
    final parentMatch =
        c.parentName?.toLowerCase().contains(normalizedQuery) ?? false;
    return nameMatch || parentMatch;
  }).toList();
}
