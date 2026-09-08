import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/foundation/paginated_state.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../../../core/packages/pocketbase/pocketbase_collections.dart';
import '../../../../core/packages/pocketbase/pocketbase_provider.dart';
import '../../../memberships/data/repositories/membership_repository.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../data/local/member_local_data_source.dart';
import '../../data/repositories/member_repository.dart';
import '../../domain/member.dart';
import '../../domain/member_active_branch_list_filter.dart';
import 'member_active_branch_filter_controller.dart';
import 'member_sort_controller.dart';

part 'paginated_members_controller.g.dart';

/// Controller for managing paginated members list.
///
/// By default the list is branch-agnostic (not tied to the global branch
/// switcher). An optional [memberActiveBranchFilterProvider] limits results to
/// members with a currently active membership valid at the selected branch.
@Riverpod(keepAlive: true)
class PaginatedMembersController extends _$PaginatedMembersController {
  MemberRepository get _repository => ref.read(memberRepositoryProvider);
  MemberLocalDataSource get _localDataSource =>
      ref.read(memberLocalDataSourceProvider);

  // Track current search state
  String? _currentSearchQuery;
  List<String>? _currentSearchFields;

  /// Gets the current sort string from the sort controller.
  String get _currentSort =>
      ref.read(memberSortControllerProvider).toSortString();

  String? get _branchFilterId => ref.read(memberActiveBranchFilterProvider);

  String? get _orgFilter => ref.read(currentBranchOrganizationFilterProvider);

  String get _branchViewSort {
    final sort = ref.read(memberSortControllerProvider);
    return activeBranchMembersSortString(
      field: sort.field,
      descending: sort.descending,
    );
  }

  PaginatedState<Member> _toPaginatedState(
    PaginatedResult<Member> result, {
    bool hasReachedEnd = false,
  }) {
    return PaginatedState<Member>(
      items: result.items,
      currentPage: result.page,
      totalItems: result.totalItems,
      totalPages: result.totalPages,
      hasReachedEnd: hasReachedEnd || !result.hasMore,
    );
  }

  Future<PaginatedResult<Member>?> _loadCachedPage({
    required int page,
    String? query,
    List<String>? fields,
  }) async {
    if (query != null && query.isNotEmpty) {
      if (page == 1) {
        final items = await _localDataSource.searchQuick(
          query,
          fields: fields,
        );
        if (items.isEmpty) return null;
        return PaginatedResult(
          items: items,
          page: 1,
          totalItems: items.length,
          totalPages: 1,
        );
      }
      return _localDataSource.searchPaginated(
        query,
        fields: fields,
        page: page,
        perPage: Pagination.membersPageSize,
        sort: _currentSort,
      );
    }

    return _localDataSource.getPaginated(
      page: page,
      perPage: Pagination.membersPageSize,
      sort: _currentSort,
    );
  }

  void _triggerBackgroundSync() {
    // Fire-and-forget full sync so search and load-more can use local data.
    unawaited(
      _repository.syncAllMembers(sort: _currentSort, filter: _orgFilter),
    );
  }

  Future<PaginatedResult<Member>> _fetchActiveAtBranchPage({
    required String branchId,
    required int page,
    String? searchQuery,
  }) async {
    final plansResult = await ref
        .read(membershipRepositoryProvider)
        .fetchAll(branchId: branchId);
    final planIds = plansResult.fold(
      (_) => <String>[],
      (plans) => plans.map((p) => p.id).toList(),
    );

    final filterString = buildActiveMembersAtBranchViewFilter(
      planIds: planIds,
      searchQuery: searchQuery,
    );
    if (filterString == null) {
      return const PaginatedResult(
        items: [],
        page: 1,
        totalItems: 0,
        totalPages: 0,
      );
    }

    final pb = ref.read(pocketbaseProvider);
    final result = await pb
        .collection(PocketBaseCollections.membersWithMembershipStatus)
        .getList(
          page: page,
          perPage: Pagination.membersPageSize,
          filter: filterString,
          sort: _branchViewSort,
        );

    final items = result.items
        .map(
          (r) => memberFromMembershipStatusView(r, baseUrl: pb.baseURL),
        )
        .toList();

    return PaginatedResult(
      items: items,
      page: result.page,
      totalItems: result.totalItems,
      totalPages: result.totalPages,
    );
  }

  @override
  Future<PaginatedState<Member>> build() async {
    _currentSearchQuery = null;
    _currentSearchFields = null;

    // Rebuild when the active-branch filter or org changes.
    final branchFilterId = ref.watch(memberActiveBranchFilterProvider);
    final orgFilter = ref.watch(currentBranchOrganizationFilterProvider);

    // Listen to sort changes and refresh
    ref.listen(memberSortControllerProvider, (_, __) {
      refresh();
    });

    if (branchFilterId != null && branchFilterId.isNotEmpty) {
      final result = await _fetchActiveAtBranchPage(
        branchId: branchFilterId,
        page: 1,
      );
      return _toPaginatedState(result);
    }

    // Without an org, do not leak cross-tenant members.
    if (orgFilter == null || orgFilter.isEmpty) {
      return const PaginatedState<Member>(
        items: [],
        currentPage: 1,
        totalItems: 0,
        totalPages: 0,
        hasReachedEnd: true,
      );
    }

    final cached = await _loadCachedPage(page: 1);
    if (cached != null && cached.items.isNotEmpty) {
      state = AsyncData(_toPaginatedState(cached));
    }

    final result = await _repository.fetchPaginated(
      page: 1,
      perPage: Pagination.membersPageSize,
      sort: _currentSort,
      filter: orgFilter,
    );

    return result.fold(
      (failure) {
        if (cached != null && cached.items.isNotEmpty) {
          return _toPaginatedState(cached);
        }
        throw failure;
      },
      (paginated) {
        _triggerBackgroundSync();
        return _toPaginatedState(paginated);
      },
    );
  }

  /// Whether search is currently active.
  bool get isSearchActive => _currentSearchQuery != null;

  /// The current search query, if any.
  String? get currentSearchQuery => _currentSearchQuery;

  /// Loads the next page.
  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        currentState.hasReachedEnd) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final branchId = _branchFilterId;

    if (branchId != null && branchId.isNotEmpty) {
      try {
        final paginated = await _fetchActiveAtBranchPage(
          branchId: branchId,
          page: nextPage,
          searchQuery: _currentSearchQuery,
        );
        state = AsyncValue.data(
          currentState.appendItems(
            paginated.items,
            page: paginated.page,
            totalItems: paginated.totalItems,
            totalPages: paginated.totalPages,
          ),
        );
      } catch (_) {
        state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
      }
      return;
    }

    final result = _currentSearchQuery != null
        ? await _repository.searchPaginated(
            _currentSearchQuery!,
            fields: _currentSearchFields,
            page: nextPage,
            perPage: Pagination.membersPageSize,
            sort: _currentSort,
            filter: _orgFilter,
          )
        : await _repository.fetchPaginated(
            page: nextPage,
            perPage: Pagination.membersPageSize,
            sort: _currentSort,
            filter: _orgFilter,
          );

    result.fold(
      (failure) {
        state = AsyncValue.data(currentState.copyWith(isLoadingMore: false));
      },
      (paginated) {
        state = AsyncValue.data(
          currentState.appendItems(
            paginated.items,
            page: paginated.page,
            totalItems: paginated.totalItems,
            totalPages: paginated.totalPages,
          ),
        );
      },
    );
  }

  /// Refreshes the list (respects current search, sort, and branch filter).
  Future<void> refresh() async {
    final branchId = _branchFilterId;
    if (branchId != null && branchId.isNotEmpty) {
      final cached = state.value;
      if (cached == null || cached.items.isEmpty) {
        state = const AsyncValue.loading();
      }
      try {
        final paginated = await _fetchActiveAtBranchPage(
          branchId: branchId,
          page: 1,
          searchQuery: _currentSearchQuery,
        );
        state = AsyncData(_toPaginatedState(paginated));
      } catch (error, stackTrace) {
        if (cached != null && cached.items.isNotEmpty) {
          state = AsyncData(cached);
          return;
        }
        state = AsyncError(error, stackTrace);
      }
      return;
    }

    final cached = state.value;
    if (cached == null || cached.items.isEmpty) {
      state = const AsyncValue.loading();
    }

    final cachedPage = await _loadCachedPage(
      page: 1,
      query: _currentSearchQuery,
      fields: _currentSearchFields,
    );
    if (cachedPage != null &&
        cachedPage.items.isNotEmpty &&
        (cached == null || cached.items.isEmpty)) {
      state = AsyncData(_toPaginatedState(cachedPage));
    }

    final result = _currentSearchQuery != null
        ? await _repository.searchPaginated(
            _currentSearchQuery!,
            fields: _currentSearchFields,
            page: 1,
            perPage: Pagination.membersPageSize,
            sort: _currentSort,
            filter: _orgFilter,
          )
        : await _repository.fetchPaginated(
            page: 1,
            perPage: Pagination.membersPageSize,
            sort: _currentSort,
            filter: _orgFilter,
          );

    result.fold(
      (failure) {
        if (cached != null && cached.items.isNotEmpty) {
          state = AsyncData(cached);
          return;
        }
        if (cachedPage != null && cachedPage.items.isNotEmpty) {
          state = AsyncData(_toPaginatedState(cachedPage));
          return;
        }
        state = AsyncError(failure, StackTrace.current);
      },
      (paginated) {
        _triggerBackgroundSync();
        state = AsyncData(_toPaginatedState(paginated));
      },
    );
  }

  /// Searches members (resets to page 1).
  Future<void> search(String query, {List<String>? fields}) async {
    if (query.isEmpty) {
      return clearSearch();
    }

    _currentSearchQuery = query;
    _currentSearchFields = fields;

    final branchId = _branchFilterId;
    if (branchId != null && branchId.isNotEmpty) {
      try {
        final paginated = await _fetchActiveAtBranchPage(
          branchId: branchId,
          page: 1,
          searchQuery: query,
        );
        state = AsyncData(_toPaginatedState(paginated));
      } catch (error, stackTrace) {
        state = AsyncError(error, stackTrace);
      }
      return;
    }

    final cached = await _loadCachedPage(page: 1, query: query, fields: fields);
    if (cached != null && cached.items.isNotEmpty) {
      state = AsyncData(_toPaginatedState(cached));
    }
    // Otherwise keep previous data so the list panel (and search input) stay mounted.

    final result = await _repository.searchPaginated(
      query,
      fields: fields,
      page: 1,
      perPage: Pagination.membersPageSize,
      sort: _currentSort,
      filter: _orgFilter,
    );

    result.fold(
      (failure) {
        if (cached != null && cached.items.isNotEmpty) {
          state = AsyncData(_toPaginatedState(cached));
          return;
        }
        state = AsyncError(failure, StackTrace.current);
      },
      (paginated) {
        _triggerBackgroundSync();
        state = AsyncData(_toPaginatedState(paginated));
      },
    );
  }

  /// Clears search and reloads all members.
  Future<void> clearSearch() async {
    _currentSearchQuery = null;
    _currentSearchFields = null;
    return refresh();
  }

  /// Creates a new member.
  Future<Member?> createMember(Member member) async {
    final result = await _repository.create(member);
    return result.fold((failure) => null, (created) {
      state.whenData((currentState) {
        state = AsyncValue.data(currentState.prependItem(created));
      });
      return created;
    });
  }

  /// Updates an existing member.
  Future<bool> updateMember(Member member) async {
    final result = await _repository.update(member);
    return result.fold((failure) => false, (updated) {
      state.whenData((currentState) {
        state = AsyncValue.data(
          currentState.updateItem(updated, (m) => m.id == updated.id),
        );
      });
      return true;
    });
  }

  /// Deletes a member.
  Future<bool> deleteMember(String id) async {
    final result = await _repository.delete(id);
    return result.fold((failure) => false, (_) {
      state.whenData((currentState) {
        state = AsyncValue.data(currentState.removeItem((m) => m.id == id));
      });
      return true;
    });
  }
}
