import 'package:hzn_gyms/src/features/dashboard/presentation/controllers/dashboard_members_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DashboardMember', () {
    final endDate = DateTime.now().add(const Duration(days: 10));

    test('active status exposes days left and display date', () {
      final member = DashboardMember(
        id: 'm1',
        name: 'Juan',
        expirationDate: endDate,
        membershipStatus: 'active',
      );

      expect(member.displayExpirationDate, endDate);
      expect(member.daysUntilExpiry, isNotNull);
      expect(member.daysUntilExpiry! >= 9, isTrue);
      expect(member.hasActiveMembership, isTrue);
      expect(member.isExpired, isFalse);
    });

    test('cancelled status hides countdown despite expirationDate', () {
      final member = DashboardMember(
        id: 'm1',
        name: 'Juan',
        expirationDate: endDate,
        membershipStatus: 'cancelled',
      );

      expect(member.displayExpirationDate, isNull);
      expect(member.daysUntilExpiry, isNull);
      expect(member.monthsUntilExpiry, isNull);
      expect(member.hasActiveMembership, isFalse);
      expect(member.isExpired, isFalse);
    });

    test('null status hides countdown', () {
      final member = DashboardMember(
        id: 'm1',
        name: 'Juan',
        expirationDate: endDate,
      );

      expect(member.displayExpirationDate, isNull);
      expect(member.daysUntilExpiry, isNull);
      expect(member.hasActiveMembership, isFalse);
    });

    test('active past end date is expired', () {
      final past = DateTime.now().subtract(const Duration(days: 3));
      final member = DashboardMember(
        id: 'm1',
        name: 'Juan',
        expirationDate: past,
        membershipStatus: 'active',
      );

      expect(member.isExpired, isTrue);
      expect(member.hasActiveMembership, isFalse);
      expect(member.daysUntilExpiry, lessThan(0));
    });
  });
}
