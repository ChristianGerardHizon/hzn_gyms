import 'package:flutter_test/flutter_test.dart';

import 'package:hzn_gyms/src/features/memberships/domain/days_remaining_label.dart';

void main() {
  group('formatDaysRemainingLabel', () {
    test('returns Expires today when zero days remain', () {
      expect(formatDaysRemainingLabel(0), 'Expires today');
    });

    test('returns singular day left for one day', () {
      expect(formatDaysRemainingLabel(1), '1 day left');
    });

    test('returns plural days left for multiple days', () {
      expect(formatDaysRemainingLabel(14), '14 days left');
      expect(formatDaysRemainingLabel(2), '2 days left');
    });
  });

  group('formatMonthsRemainingLabel', () {
    test('returns singular month left for one month', () {
      expect(formatMonthsRemainingLabel(1), '1 month left');
    });

    test('returns plural months left for multiple months', () {
      expect(formatMonthsRemainingLabel(2), '2 months left');
      expect(formatMonthsRemainingLabel(11), '11 months left');
    });
  });
}
