import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/foundation/sort_config.dart';
import '../../../../core/hooks/use_debounced_callback.dart';
import '../../../../core/hooks/use_infinite_scroll.dart';
import '../../../../core/routing/org_scoped_navigation.dart';
import '../../../../core/routing/routes/members.routes.dart';
import '../../../../core/utils/list_search_field.dart';
import '../../../../core/widgets/end_of_list_indicator.dart';
import '../../../../core/widgets/sort/sort_dialog.dart';
import '../../domain/member.dart';
import '../controllers/member_active_branch_filter_controller.dart';
import '../controllers/member_branch_activity_controller.dart';
import '../controllers/member_search_controller.dart';
import '../controllers/member_sort_controller.dart';
import '../controllers/paginated_members_controller.dart';
import '../../../settings/presentation/controllers/branches_controller.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import 'dialogs/member_search_fields_dialog.dart';
import 'member_form_dialog.dart';
import 'member_list_tile.dart';

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

    // Watch providers
    final searchFields = ref.watch(memberSearchFieldsProvider);
    final activeFieldCount = searchFields.length;
    final paginatedController =
        ref.read(paginatedMembersControllerProvider.notifier);
    final sortConfig = ref.watch(memberSortControllerProvider);

    // Seed from keepAlive controller so tab remount restores input + clear.
    final initialQuery =
        initialSearchFieldText(paginatedController.currentSearchQuery);
    final searchController = useTextEditingController(text: initialQuery);
    final searchText = useState(initialQuery);
    final branchActivityAsync = ref.watch(memberBranchActivityMapProvider);
    final currentBranchId = ref.watch(currentBranchIdProvider);
    final activeBranchFilter = ref.watch(memberActiveBranchFilterProvider);
    final branchesAsync = ref.watch(branchesControllerProvider);

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

    ref.listen(memberSearchFieldsProvider, (previous, next) {
      if (previous == next || !paginatedController.isSearchActive) return;
      final query = searchController.text.trim();
      if (query.isEmpty) return;
      paginatedController.search(query, fields: next.toList());
    });

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
              showClear: shouldShowSearchClear(
                searchText: searchText.value,
                isSearchActive: paginatedController.isSearchActive,
              ),
              onSortPressed: () => _showSortDialog(context, ref),
            ),
          ),

          // Active-at-branch filter
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: branchesAsync.when(
              data: (branches) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: activeBranchFilter == null,
                      onSelected: (_) {
                        ref
                            .read(memberActiveBranchFilterProvider.notifier)
                            .clear();
                      },
                    ),
                    for (final branch in branches) ...[
                      const SizedBox(width: 8),
                      Tooltip(
                        message: branch.name,
                        child: ChoiceChip(
                          label: Text(branch.pillLabel),
                          selected: activeBranchFilter == branch.id,
                          onSelected: (_) {
                            ref
                                .read(memberActiveBranchFilterProvider.notifier)
                                .setBranchId(branch.id);
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
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
                  final branchActivityState = branchActivityAsync.value;

                  return MemberListTile(
                    member: member,
                    isSelected: isSelected,
                    activity:
                        branchActivityState?.activityByMemberId[member.id],
                    branchCodeById:
                        branchActivityState?.branchCodeById ?? const {},
                    branchNameById:
                        branchActivityState?.branchNameById ?? const {},
                    branchColorById:
                        branchActivityState?.branchColorById ?? const {},
                    currentBranchId: currentBranchId,
                    isActivityLoading: branchActivityAsync.isLoading,
                    onTap: () =>
                        MemberDetailRoute(id: member.id).goScoped(context),
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
    if (result == null || !context.mounted) return;

    ref.read(paginatedMembersControllerProvider.notifier).refresh();
    await handleMemberFormPaymentResult(context, result);
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
    required this.showClear,
    required this.onSortPressed,
  });

  final TextEditingController controller;
  final int fieldCount;
  final SortConfig sortConfig;
  final VoidCallback onSearch;
  final ValueChanged<String> onTextChanged;
  final bool showClear;
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
              suffixIcon: showClear
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
