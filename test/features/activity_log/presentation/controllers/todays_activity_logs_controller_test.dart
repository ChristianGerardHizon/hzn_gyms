import 'package:hzn_gyms/src/core/foundation/failure.dart';
import 'package:hzn_gyms/src/core/foundation/type_defs.dart';
import 'package:hzn_gyms/src/features/activity_log/data/repositories/activity_log_repository.dart';
import 'package:hzn_gyms/src/features/activity_log/domain/activity_log.dart';
import 'package:hzn_gyms/src/features/activity_log/domain/activity_log_filter.dart';
import 'package:hzn_gyms/src/features/activity_log/presentation/controllers/todays_activity_logs_controller.dart';
import 'package:hzn_gyms/src/features/settings/presentation/controllers/current_branch_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const ActivityLogQuery());
  });

  late MockActivityLogRepository repo;

  ProviderContainer createContainer({
    String? branchId = 'branch-1',
    List<ActivityLog>? logs,
    Failure? failure,
  }) {
    repo = MockActivityLogRepository();
    when(
      () => repo.fetchPaginated(
        query: any(named: 'query'),
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
      ),
    ).thenAnswer((_) async {
      if (failure != null) return left(failure);
      final items = logs ?? <ActivityLog>[];
      return right(
        PaginatedResult(
          items: items,
          page: 1,
          totalItems: items.length,
          totalPages: 1,
        ),
      );
    });

    return ProviderContainer(
      overrides: [
        activityLogRepositoryProvider.overrideWithValue(repo),
        currentBranchIdProvider.overrideWithValue(branchId),
      ],
    );
  }

  test('queries today and the selected branch', () async {
    final container = createContainer(logs: [buildActivityLog()]);
    addTearDown(container.dispose);

    final state = await container.read(
      todaysActivityLogsControllerProvider.future,
    );

    expect(state.items, hasLength(1));

    final captured =
        verify(
              () => repo.fetchPaginated(
                query: captureAny(named: 'query'),
                page: 1,
                perPage: any(named: 'perPage'),
              ),
            ).captured.single
            as ActivityLogQuery;

    final now = DateTime.now();
    expect(captured.branchId, 'branch-1');
    expect(captured.startDate?.year, now.year);
    expect(captured.startDate?.month, now.month);
    expect(captured.startDate?.day, now.day);
    expect(captured.endDate?.year, now.year);
    expect(captured.endDate?.month, now.month);
    expect(captured.endDate?.day, now.day);
  });

  test('returns empty state when there are no logs', () async {
    final container = createContainer(logs: const []);
    addTearDown(container.dispose);

    final state = await container.read(
      todaysActivityLogsControllerProvider.future,
    );

    expect(state.isEmpty, isTrue);
  });
}
