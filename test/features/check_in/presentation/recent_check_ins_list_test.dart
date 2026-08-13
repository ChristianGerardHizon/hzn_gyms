import 'package:ebe_gym/src/core/permissions/current_user_permissions.dart';
import 'package:ebe_gym/src/core/widgets/branch_code_pill.dart';
import 'package:ebe_gym/src/features/check_in/domain/check_in.dart';
import 'package:ebe_gym/src/features/check_in/presentation/controllers/check_in_controller.dart';
import 'package:ebe_gym/src/features/check_in/presentation/widgets/last_check_in_panel.dart';
import 'package:ebe_gym/src/features/check_in/presentation/widgets/recent_check_ins_list.dart';
import 'package:ebe_gym/src/features/members/presentation/controllers/member_provider.dart';
import 'package:ebe_gym/src/features/memberships/domain/member_membership.dart';
import 'package:ebe_gym/src/features/memberships/presentation/controllers/member_membership_add_ons_provider.dart';
import 'package:ebe_gym/src/features/memberships/presentation/controllers/membership_provider.dart';
import 'package:ebe_gym/src/features/memberships/presentation/widgets/member_membership_detail_dialog.dart';
import 'package:ebe_gym/src/features/settings/domain/branch.dart';
import 'package:ebe_gym/src/features/settings/presentation/controllers/branches_controller.dart';
import 'package:ebe_gym/src/features/settings/presentation/controllers/current_branch_controller.dart';
import 'package:ebe_gym/src/features/users/domain/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../../../helpers/fixtures.dart';

class _FakeCheckInController extends CheckInController {
  _FakeCheckInController(this._checkIns);

  final List<CheckIn> _checkIns;

  @override
  Future<List<CheckIn>> build() async => _checkIns;
}

class _FixedPermissions extends CurrentUserPermissionsController {
  _FixedPermissions(this._permissions);

  final CurrentUserPermissions _permissions;

  @override
  Future<CurrentUserPermissions> build() async => _permissions;
}

class _FakeBranchesController extends BranchesController {
  _FakeBranchesController(this._branches);

  final List<Branch> _branches;

  @override
  Future<List<Branch>> build() async => _branches;
}

void main() {
  const branchA = Branch(
    id: 'branch-a',
    name: 'Bacolod Branch',
    code: 'BCD',
    address: 'x',
    contactNumber: '1',
  );
  const branchB = Branch(
    id: 'branch-b',
    name: 'Talisay Branch',
    code: 'TAL',
    address: 'y',
    contactNumber: '2',
  );

  group('RecentCheckInsList membership modal', () {
    Future<void> pumpList(
      WidgetTester tester, {
      required List<CheckIn> checkIns,
      MemberMembership? membership,
      bool viewingAll = false,
      bool canVoid = false,
      Size? surfaceSize,
      List<Branch> branches = const [branchA, branchB],
    }) async {
      if (surfaceSize != null) {
        tester.view.physicalSize = surfaceSize;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
      }

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            checkInControllerProvider.overrideWith(
              () => _FakeCheckInController(checkIns),
            ),
            branchesControllerProvider.overrideWith(
              () => _FakeBranchesController(branches),
            ),
            viewingAllBranchesProvider.overrideWithValue(viewingAll),
            for (final checkIn in checkIns)
              memberActiveMembershipProvider(
                checkIn.memberId,
              ).overrideWith((ref) async => membership),
            for (final checkIn in checkIns)
              memberProvider(checkIn.memberId).overrideWith(
                (ref) async => buildMember(
                  id: checkIn.memberId,
                  name: checkIn.memberName ?? 'Jane Doe',
                ),
              ),
            currentUserPermissionsProvider.overrideWith(
              () => _FixedPermissions(
                CurrentUserPermissions(
                  permissions: {
                    Permissions.membershipsView,
                    if (canVoid) Permissions.checkInsVoid,
                  },
                ),
              ),
            ),
            if (membership != null) ...[
              membershipProvider(
                membership.membershipId,
              ).overrideWith((ref) async => buildMembership()),
              memberMembershipAddOnsProvider(
                membership.id,
              ).overrideWith((ref) async => []),
            ],
          ],
          child: const MaterialApp(home: Scaffold(body: RecentCheckInsList())),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('opens membership modal when a check-in is tapped', (
      tester,
    ) async {
      final membership = buildMemberMembership(membershipName: 'Monthly Plan');
      await pumpList(
        tester,
        checkIns: [buildCheckIn(memberId: 'member-1', memberName: 'Jane Doe')],
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
        checkIns: [buildCheckIn(memberId: 'member-1', memberName: 'Jane Doe')],
        membership: null,
      );

      await tester.tap(find.text('Jane Doe'));
      await tester.pumpAndSettle();

      expect(find.byType(MemberMembershipDetailDialog), findsNothing);
      expect(find.text('No active membership'), findsOneWidget);
    });

    testWidgets('shows branch code pills when viewing all branches', (
      tester,
    ) async {
      await pumpList(
        tester,
        viewingAll: true,
        checkIns: [
          buildCheckIn(
            id: 'ci-1',
            memberId: 'member-1',
            memberName: 'Jane Doe',
            branchId: 'branch-a',
          ),
          buildCheckIn(
            id: 'ci-2',
            memberId: 'member-2',
            memberName: 'John Smith',
            branchId: 'branch-b',
          ),
        ],
      );

      expect(find.byType(BranchCodePill), findsNWidgets(2));
      expect(find.text('BCD'), findsOneWidget);
      expect(find.text('TAL'), findsOneWidget);
    });

    testWidgets('hides branch code pills when a single branch is selected', (
      tester,
    ) async {
      await pumpList(
        tester,
        viewingAll: false,
        checkIns: [
          buildCheckIn(
            memberId: 'member-1',
            memberName: 'Jane Doe',
            branchId: 'branch-a',
          ),
        ],
      );

      expect(find.byType(BranchCodePill), findsNothing);
    });

    testWidgets('shows membership end date left of status badge', (
      tester,
    ) async {
      final endDate = DateTime(2026, 12, 15);
      await pumpList(
        tester,
        canVoid: true,
        checkIns: [buildCheckIn(memberId: 'member-1', memberName: 'Jane Doe')],
        membership: buildMemberMembership(endDate: endDate),
      );

      final dateFinder = find.text(DateFormat('MMM d, yyyy').format(endDate));
      final badgeFinder = find.byIcon(Icons.verified);
      expect(dateFinder, findsOneWidget);
      expect(badgeFinder, findsOneWidget);
      expect(find.byTooltip('Void check-in'), findsOneWidget);
      expect(
        tester.getTopLeft(dateFinder).dx,
        lessThan(tester.getTopLeft(badgeFinder).dx),
      );
    });

    testWidgets('shows Expired when member has no active membership', (
      tester,
    ) async {
      await pumpList(
        tester,
        checkIns: [buildCheckIn(memberId: 'member-1', memberName: 'Jane Doe')],
      );

      expect(find.text('Expired'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('Expired')).dx,
        lessThan(tester.getTopLeft(find.byIcon(Icons.cancel_outlined)).dx),
      );
    });

    testWidgets(
      'keeps name, time, expiry, and void visible on a narrow screen',
      (tester) async {
        final endDate = DateTime(2026, 12, 15);
        final checkInTime = DateTime(2026, 8, 14, 14, 30);
        await pumpList(
          tester,
          canVoid: true,
          surfaceSize: const Size(400, 800),
          checkIns: [
            buildCheckIn(
              memberId: 'member-1',
              memberName: 'Jane Doe',
              checkInTime: checkInTime,
            ),
          ],
          membership: buildMemberMembership(endDate: endDate),
        );

        final dateFinder = find.text(DateFormat('MMM d, yyyy').format(endDate));
        final badgeFinder = find.byIcon(Icons.verified);
        expect(find.text('Jane Doe'), findsOneWidget);
        expect(
          find.textContaining(DateFormat('hh:mm a').format(checkInTime)),
          findsOneWidget,
        );
        expect(dateFinder, findsOneWidget);
        expect(badgeFinder, findsOneWidget);
        expect(find.byTooltip('Void check-in'), findsOneWidget);
        expect(
          tester.getTopLeft(dateFinder).dx,
          lessThan(tester.getTopLeft(badgeFinder).dx),
        );
      },
    );
  });
}
