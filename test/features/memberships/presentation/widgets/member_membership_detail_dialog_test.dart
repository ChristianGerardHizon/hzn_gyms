import 'package:hzn_gyms/src/core/permissions/current_user_permissions.dart';
import 'package:hzn_gyms/src/core/widgets/cached_avatar.dart';
import 'package:hzn_gyms/src/features/members/presentation/controllers/member_provider.dart';
import 'package:hzn_gyms/src/features/memberships/domain/member_membership.dart';
import 'package:hzn_gyms/src/features/memberships/domain/member_membership_add_on.dart';
import 'package:hzn_gyms/src/features/memberships/presentation/controllers/member_membership_add_ons_provider.dart';
import 'package:hzn_gyms/src/features/memberships/presentation/controllers/membership_provider.dart';
import 'package:hzn_gyms/src/features/memberships/presentation/widgets/member_membership_detail_dialog.dart';
import 'package:hzn_gyms/src/features/sales/presentation/controllers/sale_provider.dart';
import 'package:hzn_gyms/src/features/sales/presentation/widgets/sale_status_chip.dart';
import 'package:hzn_gyms/src/features/users/domain/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../helpers/fixtures.dart';

class _FakeCurrentUserPermissionsController
    extends CurrentUserPermissionsController {
  _FakeCurrentUserPermissionsController(this._permissions);

  final CurrentUserPermissions _permissions;

  @override
  Future<CurrentUserPermissions> build() async => _permissions;
}

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
      bool showPhoto = false,
    }) async {
      final mm = membershipOverride ?? membership;
      final saleId = mm.saleId?.trim();

      // Desktop-sized surface — matches where the tall empty dialog was reported.
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserPermissionsProvider.overrideWith(
              () => _FakeCurrentUserPermissionsController(permissions),
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
            memberProvider(mm.memberId).overrideWith(
              (ref) async => buildMember(
                id: mm.memberId,
                name: 'GEROME AMAR',
              ).copyWith(photo: 'https://example.com/photo.jpg'),
            ),
            if (saleId != null && saleId.isNotEmpty)
              saleProvider(saleId).overrideWith(
                (ref) async => buildSale(
                  id: saleId,
                  receiptNumber: 'RCP-1001',
                  totalAmount: 900,
                  status: 'paid',
                  isPaid: true,
                ),
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
                      showPhoto: showPhoto,
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
      expect(find.text('Sale'), findsNothing);
      expect(find.byType(CachedAvatar), findsNothing);

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

    testWidgets('shows linked sale when membership has a saleId', (
      tester,
    ) async {
      await openDialog(
        tester,
        membershipOverride: membership.copyWith(saleId: 'sale-linked-1'),
      );

      expect(find.text('Sale'), findsOneWidget);
      expect(find.text('RCP-1001'), findsOneWidget);
      expect(find.text('₱900.00'), findsWidgets);
      expect(find.byType(SaleStatusChip), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
    });

    testWidgets('tapping linked sale closes dialog and opens sale detail', (
      tester,
    ) async {
      late final GoRouter router;
      router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => showMemberMembershipDetailDialog(
                    context,
                    memberMembership: membership.copyWith(
                      saleId: 'sale-linked-1',
                    ),
                    memberId: membership.memberId,
                    memberName: 'GEROME AMAR',
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/sales/:id',
            builder: (context, state) => Scaffold(
              body: Text('Sale detail ${state.pathParameters['id']}'),
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserPermissionsProvider.overrideWith(
              () => _FakeCurrentUserPermissionsController(
                CurrentUserPermissions.empty,
              ),
            ),
            membershipProvider(membership.membershipId).overrideWith(
              (ref) async => buildMembership(price: 900),
            ),
            memberMembershipAddOnsProvider(membership.id).overrideWith(
              (ref) async => <MemberMembershipAddOn>[],
            ),
            saleProvider('sale-linked-1').overrideWith(
              (ref) async => buildSale(
                id: 'sale-linked-1',
                receiptNumber: 'RCP-1001',
                totalAmount: 900,
                status: 'paid',
                isPaid: true,
              ),
            ),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Membership Details'), findsOneWidget);
      await tester.tap(find.text('RCP-1001'));
      await tester.pumpAndSettle();

      expect(find.text('Membership Details'), findsNothing);
      expect(find.text('Sale detail sale-linked-1'), findsOneWidget);
    });

    testWidgets('shows member photo when showPhoto is true', (tester) async {
      await openDialog(tester, showPhoto: true);

      expect(find.byType(CachedAvatar), findsOneWidget);
      final avatar = tester.widget<CachedAvatar>(find.byType(CachedAvatar));
      expect(avatar.imageUrl, 'https://example.com/photo.jpg');
      expect(avatar.radius, 48);
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
