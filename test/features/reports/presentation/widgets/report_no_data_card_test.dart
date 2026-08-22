import 'package:kylie_gym/src/features/reports/presentation/widgets/report_no_data_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('hasReportChartData', () {
    test('returns false for empty map', () {
      expect(hasReportChartData({}), isFalse);
    });

    test('returns false when all values are zero or negative', () {
      expect(hasReportChartData({'cash': 0, 'gcash': 0}), isFalse);
      expect(hasReportChartData({'cash': -1}), isFalse);
    });

    test('returns true when any value is positive', () {
      expect(hasReportChartData({'cash': 0, 'gcash': 10}), isTrue);
      expect(hasReportChartData({'cash': 0.01}), isTrue);
    });
  });
}
