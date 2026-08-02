import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/foundation/paginated_state.dart';
import '../../../../core/hooks/use_debounced_callback.dart';
import '../../../../core/hooks/use_infinite_scroll.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../../core/utils/list_search_field.dart';
import '../../../../core/widgets/end_of_list_indicator.dart';
import '../../domain/user.dart';
import '../controllers/paginated_users_controller.dart';
import '../controllers/user_search_controller.dart';
import 'dialogs/search_fields_dialog.dart';
import 'user_avatar.dart';

/// User list panel with search header and infinite scroll.
///
/// Used in both mobile list page and tablet two-pane layout.
class UserListPanel extends HookConsumerWidget {
  const UserListPanel({
    super.key,
    required this.paginatedState,
    required this.selectedId,
    required this.onUserTap,
    required this.onRefresh,
    required this.onLoadMore,
  });

  final PaginatedState<User> paginatedState;
  final String? selectedId;
  final ValueChanged<User> onUserTap;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = Translations.of(context);

    // Watch providers
    final searchFields = ref.watch(userSearchFieldsProvider);
    final activeFieldCount = searchFields.length;
    final paginatedController = ref.read(
      paginatedUsersControllerProvider.notifier,
    );

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

      final fields = ref.read(userSearchFieldsProvider).toList();
      paginatedController.search(query, fields: fields);
    }

    final debouncedSearch = useDebouncedCallback<String>(
      (_) => performSearch(),
    );

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
      onLoadMore: onLoadMore,
      hasMore: !paginatedState.hasReachedEnd,
      isLoading: paginatedState.isLoadingMore,
    );

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          color: theme.colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              Text(t.navigation.users, style: theme.textTheme.titleLarge),
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
            onSearch: performSearch,
            onTextChanged: onSearchTextChanged,
            showClear: shouldShowSearchClear(
              searchText: searchText.value,
              isSearchActive: paginatedController.isSearchActive,
            ),
          ),
        ),

        // User list
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

                final user = paginatedState.items[index];
                final isSelected = user.id == selectedId;

                return ListTile(
                  leading: UserAvatar(user: user),
                  title: Text(
                    user.name,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text('${user.displayRole} - ${user.username}'),
                  selected: isSelected,
                  selectedTileColor: theme.colorScheme.primaryContainer,
                  trailing: isSelected ? const Icon(Icons.chevron_right) : null,
                  onTap: () => onUserTap(user),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchInput extends StatelessWidget {
  const _SearchInput({
    required this.controller,
    required this.fieldCount,
    required this.onSearch,
    required this.onTextChanged,
    required this.showClear,
  });

  final TextEditingController controller;
  final int fieldCount;
  final VoidCallback onSearch;
  final ValueChanged<String> onTextChanged;
  final bool showClear;

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
        Badge(
          isLabelVisible: fieldCount > 1,
          label: Text('$fieldCount'),
          child: IconButton.filledTonal(
            icon: const Icon(Icons.tune),
            onPressed: () => showUserSearchFieldsDialog(context),
            tooltip: t.common.filter,
          ),
        ),
      ],
    );
  }
}
