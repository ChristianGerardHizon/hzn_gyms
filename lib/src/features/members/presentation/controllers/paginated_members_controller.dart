import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/foundation/paginated_state.dart';
import '../../data/repositories/member_repository.dart';
import '../../domain/member.dart';
import 'member_sort_controller.dart';

part 'paginated_members_controller.g.dart';

/// Controller for managing paginated members list.
@Riverpod(keepAlive: true)
class PaginatedMembersController extends _$PaginatedMembersController {
  MemberRepository get _repository => ref.read(memberRepositoryProvider);

  // Track current search state
  String? _currentSearchQuery;
  List<String>? _currentSearchFields;

  /// Gets the current sort string from the sort controller.
  String get _currentSort =>
      ref.read(memberSortControllerProvider).toSortString();

  @override
  Future<PaginatedState<Member>> build() async {
    _currentSearchQuery = null;
    _currentSearchFields = null;

    // Listen to sort changes and refresh
    ref.listen(memberSortControllerProvider, (_, __) {
      refresh();
    });

    final result = await _repository.fetchPaginated(
      page: 1,
      perPage: Pagination.defaultPageSize,
      sort: _currentSort,
    );

    return result.fold(
      (failure) => throw failure,
      (paginated) => PaginatedState<Member>(
        items: paginated.items,
        currentPage: paginated.page,
        totalItems: paginated.totalItems,
        totalPages: paginated.totalPages,
        hasReachedEnd: !paginated.hasMore,
      ),
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
            perPage: Pagination.defaultPageSize,
            sort: _currentSort,
          )
        : await _repository.fetchPaginated(
            page: nextPage,
            perPage: Pagination.defaultPageSize,
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
    state = const AsyncValue.loading();

    final result = _currentSearchQuery != null
        ? await _repository.searchPaginated(
            _currentSearchQuery!,
            fields: _currentSearchFields,
            page: 1,
            perPage: Pagination.defaultPageSize,
            sort: _currentSort,
          )
        : await _repository.fetchPaginated(
            page: 1,
            perPage: Pagination.defaultPageSize,
            sort: _currentSort,
          );

    result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
      },
      (paginated) {
        state = AsyncData(PaginatedState<Member>(
          items: paginated.items,
          currentPage: paginated.page,
          totalItems: paginated.totalItems,
          totalPages: paginated.totalPages,
          hasReachedEnd: !paginated.hasMore,
        ));
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

    state = const AsyncValue.loading();

    final result = await _repository.searchPaginated(
      query,
      fields: fields,
      page: 1,
      perPage: Pagination.defaultPageSize,
      sort: _currentSort,
    );

    result.fold(
      (failure) {
        state = AsyncError(failure, StackTrace.current);
      },
      (paginated) {
        state = AsyncData(PaginatedState<Member>(
          items: paginated.items,
          currentPage: paginated.page,
          totalItems: paginated.totalItems,
          totalPages: paginated.totalPages,
          hasReachedEnd: !paginated.hasMore,
        ));
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
    return result.fold(
      (failure) => null,
      (created) {
        state.whenData((currentState) {
          state = AsyncValue.data(currentState.prependItem(created));
        });
        return created;
      },
    );
  }

  /// Updates an existing member.
  Future<bool> updateMember(Member member) async {
    final result = await _repository.update(member);
    return result.fold(
      (failure) => false,
      (updated) {
        state.whenData((currentState) {
          state = AsyncValue.data(
            currentState.updateItem(updated, (m) => m.id == updated.id),
          );
        });
        return true;
      },
    );
  }

  /// Deletes a member.
  Future<bool> deleteMember(String id) async {
    final result = await _repository.delete(id);
    return result.fold(
      (failure) => false,
      (_) {
        state.whenData((currentState) {
          state = AsyncValue.data(
            currentState.removeItem((m) => m.id == id),
          );
        });
        return true;
      },
    );
  }
}
