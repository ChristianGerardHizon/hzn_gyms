import 'package:flutter_test/flutter_test.dart';
import 'package:ebe_gym/src/core/foundation/paginated_state.dart';
import 'package:ebe_gym/src/core/foundation/sort_config.dart';

void main() {
  group('PaginatedState', () {
    test('hasMore is true when pages remain', () {
      const state = PaginatedState<int>(
        items: [1],
        currentPage: 1,
        totalPages: 3,
      );
      expect(state.hasMore, isTrue);
    });

    test('hasMore is false when hasReachedEnd', () {
      const state = PaginatedState<int>(
        items: [1],
        currentPage: 1,
        totalPages: 3,
        hasReachedEnd: true,
      );
      expect(state.hasMore, isFalse);
    });

    test('appendItems concatenates and updates metadata', () {
      final state = const PaginatedState<int>(items: [1, 2])
          .appendItems([3], page: 2, totalItems: 5, totalPages: 3);
      expect(state.items, [1, 2, 3]);
      expect(state.currentPage, 2);
      expect(state.totalItems, 5);
      expect(state.hasReachedEnd, isFalse);
    });

    test('appendItems marks end on last page', () {
      final state = const PaginatedState<int>(items: [1]).appendItems(
        [2],
        page: 2,
        totalItems: 2,
        totalPages: 2,
      );
      expect(state.hasReachedEnd, isTrue);
    });

    test('prependItem / updateItem / removeItem', () {
      var state = const PaginatedState<String>(
        items: ['a', 'b'],
        totalItems: 2,
      );
      state = state.prependItem('z');
      expect(state.items.first, 'z');
      expect(state.totalItems, 3);

      state = state.updateItem('B', (i) => i == 'b');
      expect(state.items, ['z', 'a', 'B']);

      state = state.removeItem((i) => i == 'a');
      expect(state.items, ['z', 'B']);
      expect(state.totalItems, 2);
    });
  });

  group('SortConfig', () {
    test('toSortString prefixes dash when descending', () {
      expect(
        const SortConfig(field: 'created').toSortString(),
        '-created',
      );
      expect(
        const SortConfig(field: 'name', descending: false).toSortString(),
        'name',
      );
    });

    test('toggleDirection flips descending', () {
      final toggled = const SortConfig(field: 'created').toggleDirection();
      expect(toggled.descending, isFalse);
      expect(toggled.toSortString(), 'created');
    });

    test('equality', () {
      expect(
        const SortConfig(field: 'a'),
        const SortConfig(field: 'a'),
      );
      expect(
        const SortConfig(field: 'a'),
        isNot(const SortConfig(field: 'b')),
      );
    });
  });
}
