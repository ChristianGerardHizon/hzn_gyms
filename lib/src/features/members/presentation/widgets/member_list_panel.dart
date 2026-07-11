import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/foundation/sort_config.dart';
import '../../../../core/hooks/use_debounced_callback.dart';
import '../../../../core/hooks/use_infinite_scroll.dart';
import '../../../../core/routing/routes/members.routes.dart';
import '../../../../core/widgets/cached_avatar.dart';
import '../../../../core/widgets/end_of_list_indicator.dart';
import '../../../../core/widgets/sort/sort_dialog.dart';
import '../../domain/member.dart';
import '../controllers/member_search_controller.dart';
import '../controllers/member_sort_controller.dart';
import '../../../sales/presentation/widgets/record_payment_dialog.dart';
import '../controllers/paginated_members_controller.dart';
import 'dialogs/member_search_fields_dialog.dart';
import 'member_form_dialog.dart';

/// List panel for displaying members with search, sort, filter, and infinite scroll.
class MemberListPanel extends HookConsumerWidget {
  const MemberListPanel({
    super.key,
    required this.members,
    required this.totalCount,
    required this.hasMore,
    required this.isLoadingMore,
  });

  final List<Member> members;
  final int totalCount;
  final bool hasMore;
  final bool isLoadingMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Local state using hooks
    final searchController = useTextEditingController();
    final searchText = useState('');

    // Watch providers
    final searchFields = ref.watch(memberSearchFieldsProvider);
    final activeFieldCount = searchFields.length;
    final paginatedController =
        ref.read(paginatedMembersControllerProvider.notifier);
    final sortConfig = ref.watch(memberSortControllerProvider);

    // Get selected member ID from current route
    final routerState = GoRouterState.of(context);
    final selectedMemberId = routerState.pathParameters['id'];

    void performSearch() {
      final query = searchController.text.trim();
      if (query.isEmpty) {
        if (paginatedController.isSearchActive) {
          paginatedController.clearSearch();
        }
        return;
      }

      final fields = ref.read(memberSearchFieldsProvider).toList();
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

    // Infinite scroll hook
    final scrollController = useInfiniteScroll(
      onLoadMore: () => paginatedController.loadMore(),
      hasMore: hasMore,
      isLoading: isLoadingMore,
      itemCount: members.length,
    );

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.surfaceContainerHighest,
            child: Row(
              children: [
                Text('Members', style: theme.textTheme.titleLarge),
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
              fieldCount: activeFieldCount,
              sortConfig: sortConfig,
              onSearch: performSearch,
              onTextChanged: onSearchTextChanged,
              searchText: searchText.value,
              onSortPressed: () => _showSortDialog(context, ref),
            ),
          ),

          // Members list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => paginatedController.refresh(),
              child: ListView.builder(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: members.length + 1,
                itemBuilder: (context, index) {
                  if (index == members.length) {
                    return EndOfListIndicator(
                      isLoadingMore: isLoadingMore,
                      hasReachedEnd: !hasMore,
                    );
                  }

                  final member = members[index];
                  final isSelected = member.id == selectedMemberId;

                  return ListTile(
                    leading: CachedAvatar(
                      imageUrl: member.photo,
                      radius: 20,
                      thumbSize: 80,
                    ),
                    title: Text(
                      member.name,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: member.mobileNumber != null &&
                            member.mobileNumber!.isNotEmpty
                        ? Text(
                            member.mobileNumber!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          )
                        : null,
                    selected: isSelected,
                    selectedTileColor: theme.colorScheme.primaryContainer,
                    onTap: () =>
                        MemberDetailRoute(id: member.id).go(context),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) async {
    final result = await showMemberFormDialog(context);
    if (result != null) {
      ref.read(paginatedMembersControllerProvider.notifier).refresh();
      if (result.sale != null && result.totalPrice != null && context.mounted) {
        await showRecordPaymentDialog(
          context,
          sale: result.sale!,
          balanceDue: result.totalPrice!,
        );
      }
    }
  }
}

void _showSortDialog(BuildContext context, WidgetRef ref) {
  final currentSort = ref.read(memberSortControllerProvider);

  showSortDialog(
    context: context,
    title: 'Sort By',
    fields: memberSortableFields,
    currentSort: currentSort,
    defaultSort: memberDefaultSort,
    onSortChanged: (config) {
      ref.read(memberSortControllerProvider.notifier).setSort(config);
    },
  );
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.fieldCount,
    required this.sortConfig,
    required this.onSearch,
    required this.onTextChanged,
    required this.searchText,
    required this.onSortPressed,
  });

  final TextEditingController controller;
  final int fieldCount;
  final SortConfig sortConfig;
  final VoidCallback onSearch;
  final ValueChanged<String> onTextChanged;
  final String searchText;
  final VoidCallback onSortPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onTextChanged,
            onSubmitted: (_) => onSearch(),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Search members...',
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
        const SizedBox(width: 8),
        IconButton.filledTonal(
          icon: Icon(
            sortConfig.descending ? Icons.arrow_downward : Icons.arrow_upward,
          ),
          onPressed: onSortPressed,
          tooltip: 'Sort',
        ),
        const SizedBox(width: 8),
        Badge(
          isLabelVisible: fieldCount > 1,
          label: Text('$fieldCount'),
          child: IconButton.filledTonal(
            icon: const Icon(Icons.tune),
            onPressed: () => showMemberSearchFieldsDialog(context),
            tooltip: 'Search Fields',
          ),
        ),
      ],
    );
  }
}
