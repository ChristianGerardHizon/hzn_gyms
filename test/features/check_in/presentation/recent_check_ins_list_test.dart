import 'package:ebe_gym/src/core/permissions/current_user_permissions.dart';
import 'package:ebe_gym/src/features/check_in/domain/check_in.dart';
import 'package:ebe_gym/src/features/check_in/presentation/controllers/check_in_controller.dart';
import 'package:ebe_gym/src/features/check_in/presentation/widgets/last_check_in_panel.dart';
import 'package:ebe_gym/src/features/check_in/presentation/widgets/recent_check_ins_list.dart';
import 'package:ebe_gym/src/features/members/presentation/controllers/member_provider.dart';
import 'package:ebe_gym/src/features/memberships/domain/member_membership.dart';
import 'package:ebe_gym/src/features/memberships/presentation/controllers/member_membership_add_ons_provider.dart';
import 'package:ebe_gym/src/features/memberships/presentation/controllers/membership_provider.dart';
import 'package:ebe_gym/src/features/memberships/presentation/widgets/member_membership_detail_dialog.dart';
import 'package:ebe_gym/src/features/users/domain/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

class _FakeCheckInController extends CheckInController {
  _FakeCheckInController(this._checkIns);

  final List<CheckIn> _checkIns;

  @override
  Future<List<CheckIn>> build() async => _checkIns;
}

void main() {
  group('RecentCheckInsList membership modal', () {
    Future<void> pumpList(
      WidgetTester tester, {
      required List<CheckIn> checkIns,
      MemberMembership? membership,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            checkInControllerProvider.overrideWith(
              () => _FakeCheckInController(checkIns),
            ),
            for (final checkIn in checkIns)
              memberActiveMembershipProvider(checkIn.memberId).overrideWith(
                (ref) async => membership,
              ),
            for (final checkIn in checkIns)
              memberProvider(checkIn.memberId).overrideWith(
                (ref) async => buildMember(
                  id: checkIn.memberId,
                  name: checkIn.memberName ?? 'Jane Doe',
                ),
              ),
            currentUserPermissionsProvider.overrideWith(
              (ref) async => const CurrentUserPermissions(
                permissions: {Permissions.membershipsView},
              ),
            ),
            if (membership != null) ...[
              membershipProvider(membership.membershipId).overrideWith(
                (ref) async => buildMembership(),
              ),
              memberMembershipAddOnsProvider(membership.id).overrideWith(
                (ref) async => [],
              ),
            ],
          ],
          child: const MaterialApp(
            home: Scaffold(body: RecentCheckInsList()),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('opens membership modal when a check-in is tapped', (
      tester,
    ) async {
      final membership = buildMemberMembership(
        membershipName: 'Monthly Plan',
      );
      await pumpList(
        tester,
        checkIns: [
          buildCheckIn(memberId: 'member-1', memberName: 'Jane Doe'),
        ],
        membership: membership,
      );

      await tester.tap(find.text('Jane Doe'));
      await tester.pumpAndSettle();

      expect(find.byType(MemberMembershipDetailDialog), findsOneWidget);
      expect(find.text('Membership Details'), findsOneWidget);

      final dialog = tester.widget<MemberMembershipDetailDialog>(
        find.byType(MemberMembershipDetailDialog),
      );
      expect(dialog.showPhoto, isTrue);
    });

    testWidgets('shows snackbar when tapped member has no membership', (
      tester,
    ) async {
      await pumpList(
        tester,
        checkIns: [
          buildCheckIn(memberId: 'member-1', memberName: 'Jane Doe'),
        ],
        membership: null,
      );

      await tester.tap(find.text('Jane Doe'));
      await tester.pumpAndSettle();

      expect(find.byType(MemberMembershipDetailDialog), findsNothing);
      expect(find.text('No active membership'), findsOneWidget);
    });
  });
}
