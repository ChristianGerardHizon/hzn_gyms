import 'package:hzn_gyms/src/features/dashboard/presentation/widgets/member_quick_view_dialog.dart';
import 'package:hzn_gyms/src/features/members/domain/member.dart';
import 'package:hzn_gyms/src/features/members/presentation/controllers/member_branch_activity_controller.dart';
import 'package:hzn_gyms/src/features/members/presentation/controllers/member_provider.dart';
import 'package:hzn_gyms/src/features/memberships/domain/member_branch_activity.dart';
import 'package:hzn_gyms/src/features/memberships/domain/member_membership.dart';
import 'package:hzn_gyms/src/features/memberships/presentation/controllers/member_memberships_controller.dart';
import 'package:hzn_gyms/src/features/settings/presentation/controllers/current_branch_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('MemberQuickViewDialog', () {
    testWidgets('shows Purchase membership when active only at another branch', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            effectiveBranchIdForWriteProvider.overrideWithValue('branch-2'),
            memberProvider('member-1').overrideWith(
              (ref) async => const Member(
                id: 'member-1',
                name: 'Jane Doe',
              ),
            ),
            memberMembershipsControllerProvider('member-1').overrideWith(
              () => _FakeMemberMembershipsController([
                buildMemberMembership(
                  membershipValidBranches: const ['branch-1'],
                ),
              ]),
            ),
            memberBranchActivityForIdsProvider('member-1').overrideWith(
              (ref) async => const MemberBranchActivityState(
                activityByMemberId: {
                  'member-1': MemberBranchActivity(branchIds: {'branch-1'}),
                },
                branchCodeById: {'branch-1': 'MAIN'},
                branchNameById: {'branch-1': 'Main Branch'},
                branchColorById: {'branch-1': 'teal'},
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: MemberQuickViewDialog(memberId: 'member-1'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No membership at this branch'), findsOneWidget);
      expect(find.text('Purchase membership'), findsOneWidget);
      expect(find.text('Add Card'), findsOneWidget);
      expect(find.text('Active at other branches'), findsOneWidget);
    });

    testWidgets('shows Renew membership when active at current branch', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            effectiveBranchIdForWriteProvider.overrideWithValue('branch-1'),
            memberProvider('member-1').overrideWith(
              (ref) async => const Member(
                id: 'member-1',
                name: 'Jane Doe',
              ),
            ),
            memberMembershipsControllerProvider('member-1').overrideWith(
              () => _FakeMemberMembershipsController([
                buildMemberMembership(
                  membershipValidBranches: const ['branch-1'],
                ),
              ]),
            ),
            memberBranchActivityForIdsProvider('member-1').overrideWith(
              (ref) async => const MemberBranchActivityState(
                activityByMemberId: {
                  'member-1': MemberBranchActivity(branchIds: {'branch-1'}),
                },
                branchCodeById: {'branch-1': 'MAIN'},
                branchNameById: {'branch-1': 'Main Branch'},
                branchColorById: {'branch-1': 'teal'},
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: MemberQuickViewDialog(memberId: 'member-1'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Renew membership'), findsOneWidget);
      expect(find.text('Add Card'), findsOneWidget);
      expect(find.text('Monthly Plan'), findsOneWidget);
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
