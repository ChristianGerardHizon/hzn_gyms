import 'package:ebe_gym/src/core/routing/routes/check_in.routes.dart';
import 'package:ebe_gym/src/features/check_in/domain/check_in.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('CheckInRecordsRoute', () {
    test('is nested under check-in', () {
      expect(CheckInRecordsRoute.path, '/check-in/records');
      expect(CheckInRecordsRoute.path.startsWith(CheckInRoute.path), isTrue);
      expect(const CheckInRecordsRoute().location, '/check-in/records');
    });
  });

  group('CheckIn record display fields', () {
    test('exposes details needed for the record detail dialog', () {
      final checkIn = buildCheckIn(
        memberName: 'Jane Doe',
        method: CheckInMethod.manual,
        checkInTime: DateTime(2026, 8, 1, 9, 30),
      );

      expect(checkIn.memberName, 'Jane Doe');
      expect(checkIn.memberId, 'member-1');
      expect(checkIn.method.displayName, 'Manual');
      expect(checkIn.checkInTime.hour, 9);
      expect(checkIn.checkInTime.minute, 30);
    });
  });
}
