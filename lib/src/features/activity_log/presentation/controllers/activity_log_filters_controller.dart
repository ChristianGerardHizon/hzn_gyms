import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/activity_log_filter.dart';

part 'activity_log_filters_controller.g.dart';

/// Mutable filter state for the activity log list.
@Riverpod(keepAlive: true)
class ActivityLogFiltersController extends _$ActivityLogFiltersController {
  @override
  ActivityLogQuery build() {
    final now = DateTime.now();
    return ActivityLogQuery(
      startDate: now.subtract(const Duration(days: activityLogDefaultLookbackDays)),
      endDate: now,
    );
  }

  void setDateRange({DateTime? startDate, DateTime? endDate}) {
    state = ActivityLogQuery(
      startDate: startDate ?? state.startDate,
      endDate: endDate ?? state.endDate,
      collection: state.collection,
      actorId: state.actorId,
      branchId: state.branchId,
      searchQuery: state.searchQuery,
    );
  }

  void setCollection(String? collection) {
    state = ActivityLogQuery(
      startDate: state.startDate,
      endDate: state.endDate,
      collection: collection,
      actorId: state.actorId,
      branchId: state.branchId,
      searchQuery: state.searchQuery,
    );
  }

  void setActorId(String? actorId) {
    state = ActivityLogQuery(
      startDate: state.startDate,
      endDate: state.endDate,
      collection: state.collection,
      actorId: actorId,
      branchId: state.branchId,
      searchQuery: state.searchQuery,
    );
  }

  void setBranchId(String? branchId) {
    state = ActivityLogQuery(
      startDate: state.startDate,
      endDate: state.endDate,
      collection: state.collection,
      actorId: state.actorId,
      branchId: branchId,
      searchQuery: state.searchQuery,
    );
  }

  void setSearchQuery(String? searchQuery) {
    state = ActivityLogQuery(
      startDate: state.startDate,
      endDate: state.endDate,
      collection: state.collection,
      actorId: state.actorId,
      branchId: state.branchId,
      searchQuery: searchQuery,
    );
  }
}
