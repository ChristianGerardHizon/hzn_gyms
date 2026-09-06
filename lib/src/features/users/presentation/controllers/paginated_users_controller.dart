import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/foundation/paginated_state.dart';
import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/user.dart';

part 'paginated_users_controller.g.dart';

/// Controller for managing paginated users list.
@Riverpod(keepAlive: true)
class PaginatedUsersController extends _$PaginatedUsersController {
  UserRepository get _repository => ref.read(userRepositoryProvider);

  // Track current search state
  String? _currentSearchQuery;
  List<String>? _currentSearchFields;

  String? get _organizationListFilter {
    final orgId = ref.read(currentOrganizationIdProvider);
    if (orgId == null || orgId.isEmpty) return null;
    return PBFilters.forOrganization(orgId).build();
  }

  @override
  Future<PaginatedState<User>> build() async {
    _currentSearchQuery = null;
    _currentSearchFields = null;

    final result = await _repository.fetchPaginated(
      page: 1,
      perPage: Pagination.defaultPageSize,
      filter: _organizationListFilter,
    );

    return result.fold(
      (failure) => throw failure,
      (paginated) => PaginatedState<User>(
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

    // Use search or regular fetch based on current state
    final result = _currentSearchQuery != null
        ? await _repository.searchPaginated(
            _currentSearchQuery!,
            fields: _currentSearchFields,
            page: nextPage,
            perPage: Pagination.defaultPageSize,
            filter: _organizationListFilter,
          )
        : await _repository.fetchPaginated(
            page: nextPage,
            perPage: Pagination.defaultPageSize,
            filter: _organizationListFilter,
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

  /// Refreshes the list (respects current search).
  Future<void> refresh() async {
    // Avoid wiping previous data so list UIs (and search inputs) stay mounted.
    if (!state.hasValue) {
      state = const AsyncValue.loading();
    }

    final result = _currentSearchQuery != null
        ? await _repository.searchPaginated(
            _currentSearchQuery!,
            fields: _currentSearchFields,
            page: 1,
            perPage: Pagination.defaultPageSize,
            filter: _organizationListFilter,
          )
        : await _repository.fetchPaginated(
            page: 1,
            perPage: Pagination.defaultPageSize,
            filter: _organizationListFilter,
          );

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (paginated) => AsyncData(
        PaginatedState<User>(
          items: paginated.items,
          currentPage: paginated.page,
          totalItems: paginated.totalItems,
          totalPages: paginated.totalPages,
          hasReachedEnd: !paginated.hasMore,
        ),
      ),
    );
  }

  /// Searches users (resets to page 1).
  Future<void> search(String query, {List<String>? fields}) async {
    if (query.isEmpty) {
      return clearSearch();
    }

    _currentSearchQuery = query;
    _currentSearchFields = fields;

    // Keep previous data so the list panel (and search input) stay mounted.
    final result = await _repository.searchPaginated(
      query,
      fields: fields,
      page: 1,
      perPage: Pagination.defaultPageSize,
      filter: _organizationListFilter,
    );

    state = result.fold(
      (failure) => AsyncError(failure, StackTrace.current),
      (paginated) => AsyncData(
        PaginatedState<User>(
          items: paginated.items,
          currentPage: paginated.page,
          totalItems: paginated.totalItems,
          totalPages: paginated.totalPages,
          hasReachedEnd: !paginated.hasMore,
        ),
      ),
    );
  }

  /// Clears search and reloads all users.
  Future<void> clearSearch() async {
    _currentSearchQuery = null;
    _currentSearchFields = null;
    return refresh();
  }

  /// Creates a new user.
  Future<User?> createUser(User user, String password) async {
    final result = await _repository.create(user, password);
    return result.fold((failure) => null, (newUser) {
      state.whenData((currentState) {
        state = AsyncValue.data(currentState.prependItem(newUser));
      });
      return newUser;
    });
  }

  /// Updates an existing user.
  Future<bool> updateUser(User user) async {
    final result = await _repository.update(user);
    return result.fold((failure) => false, (updated) {
      state.whenData((currentState) {
        state = AsyncValue.data(
          currentState.updateItem(updated, (u) => u.id == updated.id),
        );
      });
      return true;
    });
  }

  /// Deletes a user.
  Future<bool> deleteUser(String id) async {
    final result = await _repository.delete(id);
    return result.fold((failure) => false, (_) {
      state.whenData((currentState) {
        state = AsyncValue.data(currentState.removeItem((u) => u.id == id));
      });
      return true;
    });
  }

  /// Resets a user's password (admin action).
  ///
  /// Returns `null` on success, or an error message on failure.
  Future<String?> resetPassword(String userId, String newPassword) async {
    final result = await _repository.resetPassword(userId, newPassword);
    return result.fold((failure) => failure.message, (_) => null);
  }
}
