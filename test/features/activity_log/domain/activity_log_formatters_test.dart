import 'package:hzn_gyms/src/features/activity_log/domain/activity_log.dart';
import 'package:hzn_gyms/src/features/activity_log/domain/activity_log_action.dart';
import 'package:hzn_gyms/src/features/activity_log/domain/activity_log_change.dart';
import 'package:hzn_gyms/src/features/activity_log/domain/activity_log_filter.dart';
import 'package:hzn_gyms/src/features/activity_log/domain/activity_log_formatters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  setUpAll(() {
    Intl.defaultLocale = 'en_US';
  });
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
      expect(activityLogEntityLabel('members'), 'member');
    });

    test('formats values for display', () {
      expect(formatActivityLogValue(null), '—');
      expect(formatActivityLogValue(true), 'Yes');
      expect(formatActivityLogValue(false), 'No');
      expect(formatActivityLogValue(['a', 'b']), 'a, b');
    });

    test('formats money fields as pesos', () {
      final formatted = formatActivityLogValue(1234.5, field: 'amount');
      expect(formatted, contains('₱'));
      expect(formatted, contains('1,234.50'));
    });

    test('formats date-only strings', () {
      expect(formatActivityLogValue('2026-08-19'), 'Aug 19, 2026');
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

  group('formatActivityLogHeadline', () {
    test('includes actor, verb, entity, and record label', () {
      const log = ActivityLog(
        id: '1',
        action: ActivityLogAction.update,
        collection: 'members',
        recordId: 'mem-1',
        summary: 'Updated Member: Juan Dela Cruz',
        actorName: 'Chris',
      );

      expect(
        formatActivityLogHeadline(log),
        'Chris updated member Juan Dela Cruz',
      );
    });

    test('capitalizes the verb when there is no actor', () {
      const log = ActivityLog(
        id: '1',
        action: ActivityLogAction.create,
        collection: 'members',
        recordId: 'mem-1',
        summary: 'Created Member: Juan Dela Cruz',
      );

      expect(formatActivityLogHeadline(log), 'Created member Juan Dela Cruz');
    });

    test('uses voided when sale status changed to voided', () {
      const log = ActivityLog(
        id: '1',
        action: ActivityLogAction.update,
        collection: 'sales',
        recordId: 'sale-1',
        summary: 'Voided Sale: Walk-in (#R-1)',
        actorName: 'Chris',
        changes: [
          ActivityLogChange(
            field: 'status',
            oldValue: 'completed',
            newValue: 'voided',
          ),
        ],
      );

      expect(
        formatActivityLogHeadline(log),
        'Chris voided sale Walk-in (#R-1)',
      );
    });
  });

  group('formatActivityLogChangePreview', () {
    test('returns labeled old to new values for updates', () {
      const log = ActivityLog(
        id: '1',
        action: ActivityLogAction.update,
        collection: 'members',
        recordId: 'mem-1',
        summary: 'Updated Member: Juan Dela Cruz',
        changes: [
          ActivityLogChange(
            field: 'mobileNumber',
            oldValue: '0917',
            newValue: '0918',
          ),
        ],
      );

      expect(formatActivityLogChangePreview(log), 'Mobile: 0917 → 0918');
    });

    test('is null for create and delete', () {
      const created = ActivityLog(
        id: '1',
        action: ActivityLogAction.create,
        collection: 'members',
        recordId: 'mem-1',
        summary: 'Created Member: Juan',
        changes: [
          ActivityLogChange(field: 'name', oldValue: null, newValue: 'Juan'),
        ],
      );
      const deleted = ActivityLog(
        id: '2',
        action: ActivityLogAction.delete,
        collection: 'members',
        recordId: 'mem-1',
        summary: 'Deleted Member: Juan',
        changes: [
          ActivityLogChange(field: 'name', oldValue: 'Juan', newValue: null),
        ],
      );

      expect(formatActivityLogChangePreview(created), isNull);
      expect(formatActivityLogChangePreview(deleted), isNull);
    });

    test('truncates after maxChanges', () {
      const log = ActivityLog(
        id: '1',
        action: ActivityLogAction.update,
        collection: 'members',
        recordId: 'mem-1',
        summary: 'Updated Member: Juan',
        changes: [
          ActivityLogChange(field: 'address', oldValue: 'A', newValue: 'B'),
          ActivityLogChange(field: 'email', oldValue: 'a@x', newValue: 'b@x'),
          ActivityLogChange(field: 'name', oldValue: 'Juan', newValue: 'John'),
          ActivityLogChange(field: 'notes', oldValue: 'x', newValue: 'y'),
        ],
      );

      final preview = formatActivityLogChangePreview(log, maxChanges: 3);
      expect(preview, contains('+1 more'));
    });
  });
}
