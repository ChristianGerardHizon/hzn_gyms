import 'package:kylie_gym/src/core/foundation/type_defs.dart';
import 'package:kylie_gym/src/core/permissions/current_user_permissions.dart';
import 'package:kylie_gym/src/features/activity_log/data/repositories/activity_log_repository.dart';
import 'package:kylie_gym/src/features/activity_log/domain/activity_log.dart';
import 'package:kylie_gym/src/features/activity_log/domain/activity_log_change.dart';
import 'package:kylie_gym/src/features/activity_log/domain/activity_log_filter.dart';
import 'package:kylie_gym/src/features/dashboard/presentation/widgets/todays_activity_logs_dialog.dart';
import 'package:kylie_gym/src/features/settings/presentation/controllers/current_branch_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

class _FixedPermissions extends CurrentUserPermissionsController {
  _FixedPermissions(this._permissions);

  final CurrentUserPermissions _permissions;

  @override
  Future<CurrentUserPermissions> build() async => _permissions;
}

void main() {
  setUpAll(() {
    registerFallbackValue(const ActivityLogQuery());
  });

  late MockActivityLogRepository repo;

  Future<void> pumpAndOpenDialog(
    WidgetTester tester, {
    required List<ActivityLog> logs,
  }) async {
    repo = MockActivityLogRepository();
    when(
      () => repo.fetchPaginated(
        query: any(named: 'query'),
        page: any(named: 'page'),
        perPage: any(named: 'perPage'),
      ),
    ).thenAnswer((_) async {
      return right(
        PaginatedResult(
          items: logs,
          page: 1,
          totalItems: logs.length,
          totalPages: 1,
        ),
      );
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          activityLogRepositoryProvider.overrideWithValue(repo),
          currentBranchIdProvider.overrideWithValue('branch-1'),
          currentUserPermissionsProvider.overrideWith(
            () =>
                _FixedPermissions(const CurrentUserPermissions(isAdmin: true)),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showTodaysActivityLogsDialog(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets('shows empty copy when there is no activity today', (
    tester,
  ) async {
    await pumpAndOpenDialog(tester, logs: const []);

    expect(find.text("Today's Activity"), findsOneWidget);
    expect(find.text('No activity recorded today.'), findsOneWidget);
  });

  testWidgets('shows a descriptive headline and expands field diffs', (
    tester,
  ) async {
    final log = buildActivityLog(
      changes: const [
        ActivityLogChange(
          field: 'mobileNumber',
          oldValue: '0917',
          newValue: '0918',
        ),
      ],
    );
    await pumpAndOpenDialog(tester, logs: [log]);

    expect(find.text('Chris updated member Juan Dela Cruz'), findsOneWidget);
    expect(find.textContaining('Mobile: 0917 → 0918'), findsOneWidget);

    await tester.tap(find.text('Chris updated member Juan Dela Cruz'));
    await tester.pumpAndSettle();

    expect(find.text('Field'), findsOneWidget);
    expect(find.text('Before'), findsOneWidget);
    expect(find.text('After'), findsOneWidget);
    expect(find.text('0917'), findsWidgets);
    expect(find.text('0918'), findsWidgets);
  });
}
