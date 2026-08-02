import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/foundation/paginated_state.dart';
import '../../../../core/foundation/type_defs.dart';
import '../../data/local/member_local_data_source.dart';
import '../../data/repositories/member_repository.dart';
import '../../domain/member.dart';
import 'member_sort_controller.dart';

part 'paginated_members_controller.g.dart';

/// Controller for managing paginated members list.
///
/// Members are branch-agnostic — lists and search are not filtered by the
/// current branch switcher.
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
    unawaited(_repository.syncAllMembers(sort: _currentSort));
  }

  @override
  Future<PaginatedState<Member>> build() async {
    _currentSearchQuery = null;
    _currentSearchFields = null;

    // Listen to sort changes and refresh
    ref.listen(memberSortControllerProvider, (_, __) {
      refresh();
    });

    final cached = await _loadCachedPage(page: 1);
    if (cached != null && cached.items.isNotEmpty) {
      state = AsyncData(_toPaginatedState(cached));
    }

    final result = await _repository.fetchPaginated(
      page: 1,
      perPage: Pagination.membersPageSize,
      sort: _currentSort,
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

    final result = _currentSearchQuery != null
        ? await _repository.searchPaginated(
            _currentSearchQuery!,
            fields: _currentSearchFields,
            page: nextPage,
            perPage: Pagination.membersPageSize,
            sort: _currentSort,
          )
        : await _repository.fetchPaginated(
            page: nextPage,
            perPage: Pagination.membersPageSize,
            sort: _currentSort,
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

  /// Refreshes the list (respects current search and sort).
  Future<void> refresh() async {
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
          )
        : await _repository.fetchPaginated(
            page: 1,
            perPage: Pagination.membersPageSize,
            sort: _currentSort,
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
