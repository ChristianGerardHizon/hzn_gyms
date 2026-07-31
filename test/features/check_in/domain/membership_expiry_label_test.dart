import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import 'package:ebe_gym/src/features/check_in/domain/membership_expiry_label.dart';

void main() {
  final format = DateFormat('MMM dd, yyyy');

  test('formats today / tomorrow / days left', () {
    final end = DateTime(2026, 8, 1);
    expect(
      formatMembershipExpiryLabel(
        endDate: end,
        daysRemaining: 0,
        dateFormat: format,
      ),
      'Expires today (Aug 01, 2026)',
    );
    expect(
      formatMembershipExpiryLabel(
        endDate: end,
        daysRemaining: 1,
        dateFormat: format,
      ),
      'Expires tomorrow (Aug 01, 2026)',
    );
    expect(
      formatMembershipExpiryLabel(
        endDate: end,
        daysRemaining: 14,
        dateFormat: format,
      ),
      'Expires Aug 01, 2026 (14 days left)',
    );
  });

  test('omits days when unknown', () {
    expect(
      formatMembershipExpiryLabel(
        endDate: DateTime(2026, 8, 1),
        dateFormat: format,
      ),
      'Expires Aug 01, 2026',
    );
  });
}
