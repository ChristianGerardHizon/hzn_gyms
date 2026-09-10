import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/foundation/paginated_state.dart';
import '../../../users/data/repositories/user_repository.dart';
import '../../../users/domain/user.dart';

part 'platform_users_controller.g.dart';

/// Cross-org users list for platform operators (`/platform/users`).
///
/// Unlike [PaginatedUsersController], this does **not** filter by current org.
@Riverpod(keepAlive: true)
class PlatformUsersController extends _$PlatformUsersController {
  UserRepository get _repository => ref.read(userRepositoryProvider);

  String? _currentSearchQuery;
  List<String>? _currentSearchFields;

  @override
  Future<PaginatedState<User>> build() async {
    _currentSearchQuery = null;
    _currentSearchFields = null;

    final result = await _repository.fetchPaginated(
      page: 1,
      perPage: Pagination.defaultPageSize,
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

  bool get isSearchActive => _currentSearchQuery != null;

  String? get currentSearchQuery => _currentSearchQuery;

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
          )
        : await _repository.fetchPaginated(
            page: nextPage,
            perPage: Pagination.defaultPageSize,
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

  Future<void> refresh() async {
    if (!state.hasValue) {
      state = const AsyncValue.loading();
    }

    final result = _currentSearchQuery != null
        ? await _repository.searchPaginated(
            _currentSearchQuery!,
            fields: _currentSearchFields,
            page: 1,
            perPage: Pagination.defaultPageSize,
          )
        : await _repository.fetchPaginated(
            page: 1,
            perPage: Pagination.defaultPageSize,
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

  Future<void> search(String query, {List<String>? fields}) async {
    if (query.isEmpty) {
      return clearSearch();
    }

    _currentSearchQuery = query;
    _currentSearchFields = fields;

    final result = await _repository.searchPaginated(
      query,
      fields: fields,
      page: 1,
      perPage: Pagination.defaultPageSize,
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

  Future<void> clearSearch() async {
    _currentSearchQuery = null;
    _currentSearchFields = null;
    return refresh();
  }

  /// Toggles platform operator access. Returns null on success, else error.
  Future<String?> setSuperAdmin(String userId, bool value) async {
    final result = await _repository.setSuperAdmin(userId, value);
    return result.fold((failure) => failure.message, (updated) {
      state.whenData((currentState) {
        state = AsyncValue.data(
          currentState.updateItem(updated, (u) => u.id == updated.id),
        );
      });
      return null;
    });
  }
}
