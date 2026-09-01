import 'package:hzn_gyms/src/features/dashboard/domain/dashboard_greeting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('dashboardGreetingPeriod', () {
    test('returns Morning before noon', () {
      expect(
        dashboardGreetingPeriod(DateTime(2026, 8, 8, 5, 0)),
        'Morning',
      );
      expect(
        dashboardGreetingPeriod(DateTime(2026, 8, 8, 11, 59)),
        'Morning',
      );
    });

    test('returns Noon during the 12 o\'clock hour', () {
      expect(
        dashboardGreetingPeriod(DateTime(2026, 8, 8, 12, 0)),
        'Noon',
      );
      expect(
        dashboardGreetingPeriod(DateTime(2026, 8, 8, 12, 59)),
        'Noon',
      );
    });

    test('returns Afternoon from 1pm until before 5pm', () {
      expect(
        dashboardGreetingPeriod(DateTime(2026, 8, 8, 13, 0)),
        'Afternoon',
      );
      expect(
        dashboardGreetingPeriod(DateTime(2026, 8, 8, 16, 59)),
        'Afternoon',
      );
    });

    test('returns Evening from 5pm onward', () {
      expect(
        dashboardGreetingPeriod(DateTime(2026, 8, 8, 17, 0)),
        'Evening',
      );
      expect(
        dashboardGreetingPeriod(DateTime(2026, 8, 8, 23, 0)),
        'Evening',
      );
    });
  });

  group('dashboardGreeting', () {
    test('includes user name when provided', () {
      expect(
        dashboardGreeting(
          dateTime: DateTime(2026, 8, 8, 9, 0),
          userName: 'Chris',
        ),
        'Good Morning, Chris',
      );
    });

    test('omits name when blank', () {
      expect(
        dashboardGreeting(
          dateTime: DateTime(2026, 8, 8, 12, 30),
          userName: '  ',
        ),
        'Good Noon',
      );
      expect(
        dashboardGreeting(dateTime: DateTime(2026, 8, 8, 14, 0)),
        'Good Afternoon',
      );
    });
  });
}
