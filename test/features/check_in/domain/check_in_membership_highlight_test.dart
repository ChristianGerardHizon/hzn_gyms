import 'package:ebe_gym/src/features/check_in/domain/check_in_membership_highlight.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('resolveCheckInMembershipHighlight', () {
    test('returns expired when membership is null', () {
      expect(
        resolveCheckInMembershipHighlight(null),
        CheckInMembershipHighlight.expired,
      );
    });

    test('returns active when days remaining is above threshold', () {
      final membership = buildMemberMembership(
        endDate: DateTime.now().add(const Duration(days: 15)),
      );

      expect(
        resolveCheckInMembershipHighlight(membership),
        CheckInMembershipHighlight.active,
      );
    });

    test('returns nearExpiry at and below threshold', () {
      for (final days in [0, 1, 7]) {
        final membership = buildMemberMembership(
          endDate: DateTime.now().add(Duration(days: days)),
        );

        expect(
          resolveCheckInMembershipHighlight(membership),
          CheckInMembershipHighlight.nearExpiry,
          reason: 'expected nearExpiry for $days days remaining',
        );
      }
    });
  });

  group('checkInMembershipHighlightColor', () {
    test('maps each highlight to the expected color', () {
      expect(
        checkInMembershipHighlightColor(CheckInMembershipHighlight.active),
        Colors.green,
      );
      expect(
        checkInMembershipHighlightColor(CheckInMembershipHighlight.nearExpiry),
        Colors.orange,
      );
      expect(
        checkInMembershipHighlightColor(CheckInMembershipHighlight.expired),
        Colors.red,
      );
    });
  });

  group('checkInMembershipHighlightIcon', () {
    test('maps each highlight to the expected icon', () {
      expect(
        checkInMembershipHighlightIcon(CheckInMembershipHighlight.active),
        Icons.verified,
      );
      expect(
        checkInMembershipHighlightIcon(CheckInMembershipHighlight.nearExpiry),
        Icons.warning_amber_rounded,
      );
      expect(
        checkInMembershipHighlightIcon(CheckInMembershipHighlight.expired),
        Icons.cancel_outlined,
      );
    });
  });
}
