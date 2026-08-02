import 'package:ebe_gym/src/core/utils/list_search_field.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('initialSearchFieldText', () {
    test('returns empty string when query is null', () {
      expect(initialSearchFieldText(null), '');
    });

    test('returns the query when present', () {
      expect(initialSearchFieldText('john'), 'john');
    });
  });

  group('shouldShowSearchClear', () {
    test('hides clear when field empty and search inactive', () {
      expect(
        shouldShowSearchClear(searchText: '', isSearchActive: false),
        isFalse,
      );
    });

    test('shows clear when field has text', () {
      expect(
        shouldShowSearchClear(searchText: 'a', isSearchActive: false),
        isTrue,
      );
    });

    test('shows clear when search is active even if field empty', () {
      expect(
        shouldShowSearchClear(searchText: '', isSearchActive: true),
        isTrue,
      );
    });

    test('shows clear when both field has text and search is active', () {
      expect(
        shouldShowSearchClear(searchText: 'a', isSearchActive: true),
        isTrue,
      );
    });
  });
}
