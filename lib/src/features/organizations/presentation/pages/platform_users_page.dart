import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/foundation/paginated_state.dart';
import '../../../../core/hooks/use_debounced_callback.dart';
import '../../../../core/hooks/use_infinite_scroll.dart';
import '../../../../core/i18n/strings.g.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/utils/list_search_field.dart';
import '../../../../core/widgets/end_of_list_indicator.dart';
import '../../../../core/widgets/state/error_state.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../users/domain/user.dart';
import '../../../users/presentation/widgets/user_avatar.dart';
import '../controllers/platform_users_controller.dart';

/// Platform shell page: all users across orgs + toggle `superAdmin`.
class PlatformUsersPage extends HookConsumerWidget {
  const PlatformUsersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final isMobile = Breakpoints.isMobile(context);
    final horizontalPad = isMobile ? 16.0 : 24.0;
    final usersAsync = ref.watch(platformUsersControllerProvider);
    final currentUserId = ref.watch(currentAuthProvider)?.user.id;
    final controller = ref.read(platformUsersControllerProvider.notifier);

    final searchController = useTextEditingController(
      text: initialSearchFieldText(controller.currentSearchQuery),
    );
    final searchText = useState(searchController.text);
    final isSearching = useState(controller.isSearchActive);

    final debouncedSearch = useDebouncedCallback<String>((query) {
      if (query.isEmpty) {
        isSearching.value = false;
        controller.clearSearch();
      } else {
        isSearching.value = true;
        controller.search(query, fields: const ['name', 'email']);
      }
    });

    useEffect(() {
      void listener() {
        searchText.value = searchController.text;
        debouncedSearch.call(searchController.text);
      }

      searchController.addListener(listener);
      return () => searchController.removeListener(listener);
    }, [searchController]);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPad,
              isMobile ? 12 : 20,
              horizontalPad,
              isMobile ? 4 : 8,
            ),
            child: Text(
              t.organizations.platformUsersTitle,
              style:
                  (isMobile
                          ? Theme.of(context).textTheme.titleLarge
                          : Theme.of(context).textTheme.headlineMedium)
                      ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPad),
            child: SearchBar(
              controller: searchController,
              hintText: t.organizations.platformUsersSearchHint,
              leading: const Icon(Icons.search),
              trailing: [
                if (shouldShowSearchClear(
                  searchText: searchText.value,
                  isSearchActive: isSearching.value,
                ))
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      debouncedSearch.cancel();
                      searchController.clear();
                      searchText.value = '';
                      isSearching.value = false;
                      controller.clearSearch();
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: usersAsync.when(
              data: (paginated) => _PlatformUsersList(
                paginated: paginated,
                currentUserId: currentUserId,
                horizontalPad: horizontalPad,
                onRefresh: controller.refresh,
                onLoadMore: controller.loadMore,
                onToggleSuperAdmin: (user, value) async {
                  if (user.id == currentUserId) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            t.organizations.platformUsersCannotChangeSelf,
                          ),
                        ),
                      );
                    }
                    return;
                  }
                  final error = await controller.setSuperAdmin(user.id, value);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        error != null
                            ? '${t.organizations.platformUsersToggleFailed}: $error'
                            : (value
                                  ? t.organizations.platformUsersGrantSuccess
                                  : t.organizations.platformUsersRevokeSuccess),
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => ErrorState(
                message: error.toString(),
                onRetry: () => ref.invalidate(platformUsersControllerProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformUsersList extends HookConsumerWidget {
  const _PlatformUsersList({
    required this.paginated,
    required this.currentUserId,
    required this.horizontalPad,
    required this.onRefresh,
    required this.onLoadMore,
    required this.onToggleSuperAdmin,
  });

  final PaginatedState<User> paginated;
  final String? currentUserId;
  final double horizontalPad;
  final Future<void> Function() onRefresh;
  final VoidCallback onLoadMore;
  final Future<void> Function(User user, bool value) onToggleSuperAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final theme = Theme.of(context);
    final scrollController = useInfiniteScroll(
      onLoadMore: onLoadMore,
      hasMore: !paginated.hasReachedEnd,
      isLoading: paginated.isLoadingMore,
      itemCount: paginated.items.length,
    );

    if (paginated.items.isEmpty) {
      return Center(child: Text(t.organizations.platformUsersEmpty));
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.symmetric(horizontal: horizontalPad),
        itemCount:
            paginated.items.length + (paginated.hasReachedEnd ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= paginated.items.length) {
            return EndOfListIndicator(
              isLoadingMore: paginated.isLoadingMore,
              hasReachedEnd: paginated.hasReachedEnd,
            );
          }

          final user = paginated.items[index];
          final isSelf = user.id == currentUserId;
          final subtitle = [
            if (user.email != null && user.email!.isNotEmpty) user.email!,
            user.displayOrganization,
            user.displayRole,
          ].join(' · ');

          return ListTile(
            leading: UserAvatar(user: user, radius: 20),
            title: Text(user.name),
            subtitle: Text(subtitle),
            isThreeLine: true,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.organizations.platformUsersAdminLabel,
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(width: 8),
                Switch(
                  value: user.superAdmin,
                  onChanged: isSelf
                      ? null
                      : (value) => onToggleSuperAdmin(user, value),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
