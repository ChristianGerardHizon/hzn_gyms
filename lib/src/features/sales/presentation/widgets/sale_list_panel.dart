import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/foundation/paginated_state.dart';
import '../../../../core/foundation/sort_config.dart';
import '../../../../core/hooks/use_debounced_callback.dart';
import '../../../../core/hooks/use_infinite_scroll.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../../core/utils/list_search_field.dart';
import '../../../../core/widgets/branch_code_pill.dart';
import '../../../../core/widgets/end_of_list_indicator.dart';
import '../../../../core/widgets/sort/sort_dialog.dart';
import '../../../pos/domain/sale.dart';
import '../../../settings/presentation/controllers/branches_controller.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../controllers/paginated_sales_controller.dart';
import '../controllers/sale_search_controller.dart';
import '../controllers/sale_sort_controller.dart';
import '../../domain/sale_status_filter.dart';
import 'sale_status_chip.dart';
import 'dialogs/sale_search_fields_dialog.dart';

/// Sale list panel with search header and infinite scroll.
///
/// Used in both mobile list page and tablet two-pane layout.
class SaleListPanel extends HookConsumerWidget {
  const SaleListPanel({
    super.key,
    required this.paginatedState,
    required this.selectedId,
    required this.onSaleTap,
    required this.onRefresh,
    required this.onLoadMore,
  });

  final PaginatedState<Sale> paginatedState;
  final String? selectedId;
  final ValueChanged<Sale> onSaleTap;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    // Watch providers
    final searchFields = ref.watch(saleSearchFieldsProvider);
    final activeFieldCount = searchFields.length;
    final statusFilters = ref.watch(saleStatusFiltersProvider);
    final isStatusNarrowed =
        statusFilters.length < defaultSaleStatusFilters.length;
    final paginatedController =
        ref.read(paginatedSalesControllerProvider.notifier);
    final sortConfig = ref.watch(saleSortControllerProvider);
    final viewingAll = ref.watch(viewingAllBranchesProvider);
    final branches = ref.watch(branchesControllerProvider).value ?? const [];

    // Seed from keepAlive controller so tab remount restores input + clear.
    final initialQuery =
        initialSearchFieldText(paginatedController.currentSearchQuery);
    final searchController = useTextEditingController(text: initialQuery);
    final searchText = useState(initialQuery);

    void performSearch() {
      final query = searchController.text.trim();
      if (query.isEmpty) {
        if (paginatedController.isSearchActive) {
          paginatedController.clearSearch();
        }
        return;
      }

      final fields = ref.read(saleSearchFieldsProvider).toList();
      paginatedController.search(query, fields: fields);
    }

    final debouncedSearch = useDebouncedCallback<String>((_) => performSearch());

    void onSearchTextChanged(String text) {
      searchText.value = text;
      debouncedSearch.cancel();
      if (text.trim().isEmpty) {
        if (paginatedController.isSearchActive) {
          paginatedController.clearSearch();
        }
        return;
      }
      debouncedSearch.call(text);
    }

    ref.listen(saleSearchFieldsProvider, (previous, next) {
      if (previous == next || !paginatedController.isSearchActive) return;
      final query = searchController.text.trim();
      if (query.isEmpty) return;
      paginatedController.search(query, fields: next.toList());
    });

    // Infinite scroll hook
    final scrollController = useInfiniteScroll(
      onLoadMore: onLoadMore,
      hasMore: !paginatedState.hasReachedEnd,
      isLoading: paginatedState.isLoadingMore,
    );

    final currencyFormat = NumberFormat.currency(symbol: '₱');
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Text(t.navigation.salesHistory,
                    style: theme.textTheme.titleLarge),
                const Spacer(),
                Text(
                  '${paginatedState.totalItems} total',
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
              fieldCount: activeFieldCount,
              showFilterBadge: activeFieldCount > 1 || isStatusNarrowed,
              sortConfig: sortConfig,
              onSearch: performSearch,
              onTextChanged: onSearchTextChanged,
              showClear: shouldShowSearchClear(
                searchText: searchText.value,
                isSearchActive: paginatedController.isSearchActive,
              ),
              onSortPressed: () => _showSortDialog(context, ref),
            ),
          ),

          // Sales list
          Expanded(
            child: RefreshIndicator(
              onRefresh: onRefresh,
              child: ListView.builder(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                // +1 for the end indicator
                itemCount: paginatedState.items.length + 1,
                itemBuilder: (context, index) {
                  // Last item is the end indicator
                  if (index == paginatedState.items.length) {
                    return EndOfListIndicator(
                      isLoadingMore: paginatedState.isLoadingMore,
                      hasReachedEnd: paginatedState.hasReachedEnd,
                    );
                  }

                  final sale = paginatedState.items[index];
                  final isSelected = sale.id == selectedId;
                  final hasDescriptor =
                      sale.descriptor != null &&
                      sale.descriptor!.trim().isNotEmpty;
                  final subtitle = [
                    if (hasDescriptor) sale.shortReceiptNumber,
                    sale.customerDisplay,
                    sale.created != null
                        ? dateFormat.format(sale.created!)
                        : 'Unknown',
                    sale.isPaid ? 'Paid' : 'Unpaid',
                  ].join(' • ');
                  final branchPill = viewingAll
                      ? BranchCodePill.fromBranches(
                          branchId: sale.branchId,
                          branches: branches,
                          dense: true,
                        )
                      : null;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.receipt,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    title: Text(
                      sale.listTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(subtitle),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (branchPill != null) ...[
                          branchPill,
                          const SizedBox(width: 8),
                        ],
                        Text(
                          currencyFormat.format(sale.totalAmount),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SaleStatusChip(status: sale.status),
                      ],
                    ),
                    selected: isSelected,
                    selectedTileColor: theme.colorScheme.primaryContainer,
                    onTap: () => onSaleTap(sale),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

}

void _showSortDialog(BuildContext context, WidgetRef ref) {
  final t = Translations.of(context);
  final currentSort = ref.read(saleSortControllerProvider);

  // Build localized field labels
  final localizedFields = saleSortableFields.map((field) {
    final label = switch (field.key) {
      'created' => t.sort.date,
      'totalAmount' => t.sort.amount,
      'receiptNumber' => t.fields.receiptNumber,
      'customerName' => t.fields.customerName,
      _ => field.label,
    };
    return (key: field.key, label: label);
  }).toList();

  showSortDialog(
    context: context,
    title: t.sort.sortBy,
    fields: localizedFields,
    currentSort: currentSort,
    defaultSort: saleDefaultSort,
    onSortChanged: (config) {
      ref.read(saleSortControllerProvider.notifier).setSort(config);
    },
  );
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.fieldCount,
    required this.showFilterBadge,
    required this.sortConfig,
    required this.onSearch,
    required this.onTextChanged,
    required this.showClear,
    required this.onSortPressed,
  });

  final TextEditingController controller;
  final int fieldCount;
  final bool showFilterBadge;
  final SortConfig sortConfig;
  final VoidCallback onSearch;
  final ValueChanged<String> onTextChanged;
  final bool showClear;
  final VoidCallback onSortPressed;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onTextChanged,
            onSubmitted: (_) => onSearch(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: '${t.common.search}...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: showClear
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        controller.clear();
                        onTextChanged('');
                      },
                      tooltip: t.common.cancel,
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
        const SizedBox(width: 8),
        IconButton.filledTonal(
          icon: Icon(
            sortConfig.descending ? Icons.arrow_downward : Icons.arrow_upward,
          ),
          onPressed: onSortPressed,
          tooltip: t.common.sort,
        ),
        const SizedBox(width: 8),
        Badge(
          isLabelVisible: showFilterBadge,
          label: Text('$fieldCount'),
          child: IconButton.filledTonal(
            icon: const Icon(Icons.tune),
            onPressed: () => showSaleSearchFieldsDialog(context),
            tooltip: t.common.filter,
          ),
        ),
      ],
    );
  }
}
