import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/constants.dart';
import '../../../../core/foundation/paginated_state.dart';
import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/activity_log_repository.dart';
import '../../domain/activity_log.dart';
import '../../domain/activity_log_filter.dart';

part 'todays_activity_logs_controller.g.dart';

/// Paginated activity logs for the local calendar day.
///
/// Follows the global branch selector. Independent of the System page
/// 7-day filter controller.
@riverpod
class TodaysActivityLogsController extends _$TodaysActivityLogsController {
  ActivityLogRepository get _repository =>
      ref.read(activityLogRepositoryProvider);

  @override
  Future<PaginatedState<ActivityLog>> build() async {
    ref.watch(currentBranchIdProvider);
    return _fetchPage(1);
  }

  ActivityLogQuery get _effectiveQuery {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return activityLogQueryForBranch(
      ActivityLogQuery(startDate: today, endDate: today),
      ref.read(currentBranchIdProvider),
    );
  }

  Future<PaginatedState<ActivityLog>> _fetchPage(int page) async {
    final result = await _repository.fetchPaginated(
      query: _effectiveQuery,
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
    final result = await _repository.fetchPaginated(
      query: _effectiveQuery,
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
}
