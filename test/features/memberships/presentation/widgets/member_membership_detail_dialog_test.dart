import 'package:ebe_gym/src/core/permissions/current_user_permissions.dart';
import 'package:ebe_gym/src/features/memberships/domain/member_membership.dart';
import 'package:ebe_gym/src/features/memberships/domain/member_membership_add_on.dart';
import 'package:ebe_gym/src/features/memberships/presentation/controllers/member_membership_add_ons_provider.dart';
import 'package:ebe_gym/src/features/memberships/presentation/controllers/membership_provider.dart';
import 'package:ebe_gym/src/features/memberships/presentation/widgets/member_membership_detail_dialog.dart';
import 'package:ebe_gym/src/features/users/domain/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('MemberMembershipDetailDialog', () {
    late MemberMembership membership;

    setUp(() {
      membership = buildMemberMembership(
        startDate: DateTime(2026, 6, 15),
        endDate: DateTime(2026, 7, 15),
      ).copyWith(membershipName: '(ORIGINAL) Monthly Membership');
    });

    Future<void> openDialog(
      WidgetTester tester, {
      CurrentUserPermissions permissions = CurrentUserPermissions.empty,
      MemberMembership? membershipOverride,
    }) async {
      final mm = membershipOverride ?? membership;

      // Desktop-sized surface — matches where the tall empty dialog was reported.
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserPermissionsProvider.overrideWith(
              (ref) async => permissions,
            ),
            membershipProvider(mm.membershipId).overrideWith(
              (ref) async => buildMembership(price: 900),
            ),
            memberMembershipAddOnsProvider(mm.id).overrideWith(
              (ref) async => [
                MemberMembershipAddOn(
                  id: 'mma-1',
                  memberMembershipId: mm.id,
                  membershipAddOnId: 'addon-1',
                  addOnName: 'Membership Fee',
                  price: 150,
                ),
              ],
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => showMemberMembershipDetailDialog(
                      context,
                      memberMembership: mm,
                      memberId: mm.memberId,
                      memberName: 'GEROME AMAR',
                    ),
                    child: const Text('Open'),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
    }

    testWidgets('renders details and shrink-wraps without nested Dialog', (
      tester,
    ) async {
      await openDialog(tester);

      expect(find.text('Membership Details'), findsOneWidget);
      expect(find.text('GEROME AMAR'), findsOneWidget);
      expect(find.text('(ORIGINAL) Monthly Membership'), findsOneWidget);
      expect(find.text('Membership Fee'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // One Dialog from showConstrainedDialog — not a nested inner Dialog.
      expect(find.byType(Dialog), findsOneWidget);

      final column = tester.widget<Column>(
        find
            .descendant(
              of: find.byType(MemberMembershipDetailDialog),
              matching: find.byType(Column),
            )
            .first,
      );
      expect(column.mainAxisSize, MainAxisSize.min);

      // Content card should shrink-wrap, not stretch near full screen height.
      final contentSize = tester.getSize(
        find.byType(MemberMembershipDetailDialog),
      );
      expect(contentSize.height, lessThan(600));
      expect(find.text('Edit Dates'), findsNothing);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('hides edit/cancel without memberships.edit', (tester) async {
      await openDialog(
        tester,
        permissions: const CurrentUserPermissions(
          permissions: {Permissions.membershipsView},
        ),
      );

      expect(find.text('Edit Dates'), findsNothing);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('shows edit/cancel with memberships.edit', (tester) async {
      await openDialog(
        tester,
        permissions: const CurrentUserPermissions(
          permissions: {Permissions.membershipsEdit},
        ),
      );

      expect(find.text('Edit Dates'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('admin sees edit/cancel via system.admin bypass', (
      tester,
    ) async {
      await openDialog(
        tester,
        permissions: const CurrentUserPermissions(isAdmin: true),
      );

      expect(find.text('Edit Dates'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('hides cancel for cancelled membership', (tester) async {
      await openDialog(
        tester,
        permissions: const CurrentUserPermissions(
          permissions: {Permissions.membershipsEdit},
        ),
        membershipOverride: membership.copyWith(
          status: MemberMembershipStatus.cancelled,
        ),
      );

      expect(find.text('Edit Dates'), findsOneWidget);
      expect(find.text('Cancel'), findsNothing);
    });

    testWidgets('hides edit and cancel for voided membership', (tester) async {
      await openDialog(
        tester,
        permissions: const CurrentUserPermissions(
          permissions: {Permissions.membershipsEdit},
        ),
        membershipOverride: membership.copyWith(
          status: MemberMembershipStatus.voided,
        ),
      );

      expect(find.text('Edit Dates'), findsNothing);
      expect(find.text('Cancel'), findsNothing);
    });
  });
}
