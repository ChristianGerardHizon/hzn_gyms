import 'package:ebe_gym/src/core/widgets/branch_code_pill.dart';
import 'package:ebe_gym/src/features/members/presentation/widgets/member_memberships_section.dart';
import 'package:ebe_gym/src/features/memberships/domain/member_membership.dart';
import 'package:ebe_gym/src/features/memberships/presentation/controllers/member_memberships_controller.dart';
import 'package:ebe_gym/src/features/settings/domain/branch.dart';
import 'package:ebe_gym/src/features/settings/presentation/controllers/branches_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

const _testBranch = Branch(
  id: 'branch-1',
  name: 'Main Branch',
  code: 'MAIN',
  address: '123 Gym St',
  contactNumber: '555-0100',
);

void main() {
  group('MemberMembershipsSection', () {
    testWidgets('hides inactive memberships behind show other button', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            branchesControllerProvider.overrideWith(
              () => _FakeBranchesController(const [_testBranch]),
            ),
            memberMembershipsControllerProvider('member-1').overrideWith(
              () => _FakeMemberMembershipsController([
                buildMemberMembership(
                  id: 'mm-active',
                  membershipName: 'Active Plan',
                ),
                buildMemberMembership(
                  id: 'mm-expired',
                  membershipName: 'Expired Plan',
                  status: MemberMembershipStatus.expired,
                  startDate: DateTime.now().subtract(const Duration(days: 60)),
                  endDate: DateTime.now().subtract(const Duration(days: 30)),
                ),
                buildMemberMembership(
                  id: 'mm-cancelled',
                  membershipName: 'Cancelled Plan',
                  status: MemberMembershipStatus.cancelled,
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: MemberMembershipsSection(
                memberId: 'member-1',
                memberName: 'Jane Doe',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Active Plan'), findsOneWidget);
      expect(find.text('Expired Plan'), findsNothing);
      expect(find.text('Cancelled Plan'), findsNothing);
      expect(find.text('Show other memberships (2)'), findsOneWidget);

      await tester.tap(find.text('Show other memberships (2)'));
      await tester.pumpAndSettle();

      expect(find.text('Expired Plan'), findsOneWidget);
      expect(find.text('Cancelled Plan'), findsOneWidget);
      expect(find.text('Hide other memberships'), findsOneWidget);

      await tester.tap(find.text('Hide other memberships'));
      await tester.pumpAndSettle();

      expect(find.text('Expired Plan'), findsNothing);
      expect(find.text('Cancelled Plan'), findsNothing);
      expect(find.text('Show other memberships (2)'), findsOneWidget);
    });

    testWidgets('shows empty active message when only inactive exist', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            branchesControllerProvider.overrideWith(
              () => _FakeBranchesController(const [_testBranch]),
            ),
            memberMembershipsControllerProvider('member-1').overrideWith(
              () => _FakeMemberMembershipsController([
                buildMemberMembership(
                  membershipName: 'Old Plan',
                  status: MemberMembershipStatus.expired,
                  startDate: DateTime.now().subtract(const Duration(days: 60)),
                  endDate: DateTime.now().subtract(const Duration(days: 30)),
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: MemberMembershipsSection(
                memberId: 'member-1',
                memberName: 'Jane Doe',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No active memberships'), findsOneWidget);
      expect(find.text('Old Plan'), findsNothing);
      expect(find.text('Show other memberships (1)'), findsOneWidget);
    });

    testWidgets('shows sold-at branch code pill for each membership', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            branchesControllerProvider.overrideWith(
              () => _FakeBranchesController(const [_testBranch]),
            ),
            memberMembershipsControllerProvider('member-1').overrideWith(
              () => _FakeMemberMembershipsController([
                buildMemberMembership(
                  id: 'mm-active',
                  membershipName: 'Active Plan',
                  branchId: 'branch-1',
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: MemberMembershipsSection(
                memberId: 'member-1',
                memberName: 'Jane Doe',
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Active Plan'), findsOneWidget);
      expect(find.text('MAIN'), findsOneWidget);
      expect(find.text('Main Branch'), findsNothing);
      expect(find.byType(BranchCodePill), findsOneWidget);
    });
  });
}

class _FakeMemberMembershipsController extends MemberMembershipsController {
  _FakeMemberMembershipsController(this._memberships);

  final List<MemberMembership> _memberships;

  @override
  Future<List<MemberMembership>> build(String memberId) async {
    return _memberships;
  }
}

class _FakeBranchesController extends BranchesController {
  _FakeBranchesController(this._branches);

  final List<Branch> _branches;

  @override
  Future<List<Branch>> build() async => _branches;
}
