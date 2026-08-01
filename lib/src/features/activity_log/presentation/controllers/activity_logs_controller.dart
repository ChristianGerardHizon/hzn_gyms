import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/foundation/paginated_state.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/activity_log_repository.dart';
import '../../domain/activity_log.dart';
import '../../domain/activity_log_filter.dart';
import 'activity_log_filters_controller.dart';

part 'activity_logs_controller.g.dart';

/// Paginated activity log list controller.
@Riverpod(keepAlive: true)
class ActivityLogsController extends _$ActivityLogsController {
  ActivityLogRepository get _repository => ref.read(activityLogRepositoryProvider);

  @override
  Future<PaginatedState<ActivityLog>> build() async {
    ref.listen(activityLogFiltersControllerProvider, (_, __) {
      refresh();
    });

    ref.listen(currentBranchIdProvider, (_, __) {
      refresh();
    });

    return _fetchPage(1);
  }

  ActivityLogQuery get _effectiveQuery => activityLogQueryForBranch(
        ref.read(activityLogFiltersControllerProvider),
        ref.read(currentBranchIdProvider),
      );

  Future<PaginatedState<ActivityLog>> _fetchPage(int page) async {
    final effectiveQuery = _effectiveQuery;

    final result = await _repository.fetchPaginated(
      query: effectiveQuery,
      page: page,
      perPage: Pagination.defaultPageSize,
    );

    return result.fold(
      (failure) => throw failure,
      (paginated) => PaginatedState<ActivityLog>(
        items: paginated.items,
        currentPage: paginated.page,
        totalItems: paginated.totalItems,
        totalPages: paginated.totalPages,
        hasReachedEnd: !paginated.hasMore,
      ),
    );
  }

  Future<void> loadMore() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoadingMore ||
        currentState.hasReachedEnd) {
      return;
    }

    state = AsyncValue.data(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;
    final effectiveQuery = _effectiveQuery;

    final result = await _repository.fetchPaginated(
      query: effectiveQuery,
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

    state = await AsyncValue.guard(() => _fetchPage(1));
  }
}
