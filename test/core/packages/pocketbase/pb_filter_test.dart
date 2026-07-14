import 'package:flutter_test/flutter_test.dart';
import 'package:ebe_gym/src/core/packages/pocketbase/pb_filter.dart';

void main() {
  group('PBFilter.escape', () {
    test('escapes single and double quotes', () {
      expect(PBFilter.escape("O'Brien"), r"O\'Brien");
      expect(PBFilter.escape('say "hi"'), r'say \"hi\"');
    });
  });

  group('PBFilter build', () {
    test('returns null when empty', () {
      expect(PBFilter().build(), isNull);
      expect(PBFilter().buildOrEmpty(), '');
    });

    test('equals and notDeleted AND together', () {
      final filter = PBFilter().equals('name', 'John').notDeleted().build();
      expect(filter, "name = 'John' && isDeleted = false");
    });

    test('relation uses double quotes', () {
      expect(
        PBFilter().relation('member', 'abc').build(),
        'member = "abc"',
      );
    });

    test('searchFields wraps OR conditions', () {
      final filter = PBFilter()
          .searchFields('doe', ['name', 'email'])
          .build();
      expect(filter, "(name ~ 'doe' || email ~ 'doe')");
    });

    test('searchFields ignores empty query', () {
      expect(PBFilter().searchFields('', ['name']).build(), isNull);
    });

    test('or combines condition groups', () {
      final filter = PBFilter()
          .equals('a', '1')
          .or(PBFilter().equals('b', '2'))
          .build();
      expect(filter, "(a = '1') || (b = '2')");
    });

    test('after uses PocketBase UTC format', () {
      final date = DateTime.utc(2024, 1, 2, 3, 4, 5, 6);
      final filter = PBFilter().after('created', date).build();
      expect(filter, "created >= '2024-01-02 03:04:05.006Z'");
    });

    test('comparisons, contains, booleans, null checks', () {
      expect(PBFilter().greaterThan('qty', 5).build(), 'qty > 5');
      expect(PBFilter().lessOrEqual('qty', 2).build(), 'qty <= 2');
      expect(PBFilter().contains('name', "O'a").build(), r"name ~ 'O\'a'");
      expect(PBFilter().isTrue('active').isFalse('deleted').build(),
          'active = true && deleted = false');
      expect(
        PBFilter().isNull('notes').build(),
        "(notes = '' || notes = null)",
      );
      expect(
        PBFilter().isNotNull('notes').build(),
        "(notes != '' && notes != null)",
      );
    });

    test('between and isActive preset', () {
      final start = DateTime.utc(2024, 1, 1);
      final end = DateTime.utc(2024, 1, 31, 23, 59, 59);
      final filter = PBFilter().between('created', start, end).isActive().build();
      expect(filter, contains("created >= '2024-01-01 00:00:00.000Z'"));
      expect(filter, contains("created <= '2024-01-31 23:59:59.000Z'"));
      expect(filter, endsWith('isActive = true'));
    });

    test('and merges conditions', () {
      final filter = PBFilter()
          .equals('a', '1')
          .and(PBFilter().equals('b', '2'))
          .build();
      expect(filter, "a = '1' && b = '2'");
    });
  });

  group('PBFilters', () {
    test('forMember includes soft-delete', () {
      expect(
        PBFilters.forMember('m1').build(),
        'member = "m1" && isDeleted = false',
      );
    });

    test('forBranch includes soft-delete', () {
      expect(
        PBFilters.forBranch('b1').build(),
        'branch = "b1" && isDeleted = false',
      );
    });
  });
}
