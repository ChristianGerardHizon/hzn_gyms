import 'package:ebe_gym/src/features/check_in/presentation/controllers/member_check_ins_controller.dart';
import 'package:ebe_gym/src/features/check_in/presentation/widgets/last_check_in_panel.dart';
import 'package:ebe_gym/src/features/members/presentation/controllers/member_provider.dart';
import 'package:ebe_gym/src/features/memberships/domain/member_membership.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

void main() {
  group('LastCheckInPanel membership status background', () {
    Future<void> pumpPanel(
      WidgetTester tester, {
      required MemberMembership? membership,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            memberProvider('member-1').overrideWith((ref) async => null),
            memberActiveMembershipProvider('member-1').overrideWith(
              (ref) async => membership,
            ),
            memberCheckInsProvider('member-1').overrideWith((ref) async => []),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 600,
                child: LastCheckInPanel(
                  checkIn: buildCheckIn(
                    memberId: 'member-1',
                    memberName: 'Jane Doe',
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    BoxDecoration? statusDecoration(WidgetTester tester) {
      final finder = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).borderRadius ==
                BorderRadius.circular(12),
      );
      if (finder.evaluate().isEmpty) return null;
      return tester.widget<Container>(finder.first).decoration as BoxDecoration;
    }

    testWidgets('uses green background for active membership', (tester) async {
      await pumpPanel(
        tester,
        membership: buildMemberMembership(
          endDate: DateTime.now().add(const Duration(days: 15)),
        ),
      );

      final decoration = statusDecoration(tester);
      expect(decoration, isNotNull);
      expect(decoration!.color, Colors.green.withValues(alpha: 0.12));
      expect(decoration.border?.top.color, Colors.green.withValues(alpha: 0.3));
    });

    testWidgets('uses orange background for near-expiry membership', (
      tester,
    ) async {
      await pumpPanel(
        tester,
        membership: buildMemberMembership(
          endDate: DateTime.now().add(const Duration(days: 3)),
        ),
      );

      final decoration = statusDecoration(tester);
      expect(decoration, isNotNull);
      expect(decoration!.color, Colors.orange.withValues(alpha: 0.12));
      expect(
        decoration.border?.top.color,
        Colors.orange.withValues(alpha: 0.3),
      );
    });

    testWidgets('uses red background when membership is missing', (
      tester,
    ) async {
      await pumpPanel(tester, membership: null);

      final decoration = statusDecoration(tester);
      expect(decoration, isNotNull);
      expect(decoration!.color, Colors.red.withValues(alpha: 0.12));
      expect(decoration.border?.top.color, Colors.red.withValues(alpha: 0.3));
    });
  });
}
