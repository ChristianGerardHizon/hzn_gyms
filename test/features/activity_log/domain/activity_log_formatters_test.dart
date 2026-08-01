import 'package:ebe_gym/src/features/activity_log/domain/activity_log_action.dart';
import 'package:ebe_gym/src/features/activity_log/domain/activity_log_change.dart';
import 'package:ebe_gym/src/features/activity_log/domain/activity_log_filter.dart';
import 'package:ebe_gym/src/features/activity_log/domain/activity_log_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildActivityLogFilter', () {
    test('includes default 7-day created lower bound', () {
      final filter = buildActivityLogFilter(
        ActivityLogQuery(
          startDate: DateTime(2026, 7, 25),
          endDate: DateTime(2026, 8, 1),
        ),
      );

      expect(filter, contains('created >='));
      expect(filter, contains('created <'));
    });

    test('filters by collection, actor, branch, and summary search', () {
      final filter = buildActivityLogFilter(
        const ActivityLogQuery(
          collection: 'members',
          actorId: 'user123',
          branchId: 'branch456',
          searchQuery: 'updated Member',
        ),
      );

      expect(filter, contains("collection = 'members'"));
      expect(filter, contains('actor = "user123"'));
      expect(filter, contains('branch = "branch456"'));
      expect(filter, contains("summary ~ 'updated Member'"));
    });
  });

  group('activityLogQueryForBranch', () {
    const query = ActivityLogQuery(collection: 'members', branchId: 'picked');

    test('uses the selected branch id', () {
      final scoped = activityLogQueryForBranch(query, 'global');

      expect(scoped.branchId, 'global');
      expect(scoped.collection, 'members');
      expect(buildActivityLogFilter(scoped), contains('branch = "global"'));
    });

    test('keeps the query branch when viewing all branches', () {
      expect(activityLogQueryForBranch(query, null).branchId, 'picked');
      expect(
        activityLogQueryForBranch(const ActivityLogQuery(), null).branchId,
        isNull,
      );
    });

    test('never emits a nested branch filter expression', () {
      final filter = buildActivityLogFilter(
        activityLogQueryForBranch(const ActivityLogQuery(), 'branch456'),
      );

      expect(filter, contains('branch = "branch456"'));
      expect(filter, isNot(contains('isDeleted')));
      expect('"'.allMatches(filter).length.isEven, isTrue);
    });
  });

  group('activityLogFormatters', () {
    test('maps collection and field labels', () {
      expect(activityLogCollectionLabel('members'), 'Members');
      expect(activityLogFieldLabel('members', 'mobileNumber'), 'Mobile');
      expect(activityLogFieldLabel('sales', 'unknownField'), 'Unknown Field');
    });

    test('formats values for display', () {
      expect(formatActivityLogValue(null), '—');
      expect(formatActivityLogValue(true), 'Yes');
      expect(formatActivityLogValue(false), 'No');
      expect(formatActivityLogValue(['a', 'b']), 'a, b');
    });

    test('sorts changes by field name', () {
      final sorted = sortedActivityLogChanges([
        const ActivityLogChange(field: 'name', oldValue: 'a', newValue: 'b'),
        const ActivityLogChange(field: 'email', oldValue: 'x', newValue: 'y'),
      ]);

      expect(sorted.map((c) => c.field), ['email', 'name']);
    });

    test('maps action labels', () {
      expect(ActivityLogAction.update.label, 'Updated');
    });
  });
}
