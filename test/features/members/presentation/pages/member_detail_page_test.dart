import 'package:hzn_gyms/src/features/check_in/presentation/controllers/member_check_ins_controller.dart';
import 'package:hzn_gyms/src/features/member_cards/domain/member_card.dart';
import 'package:hzn_gyms/src/features/member_cards/presentation/controllers/member_cards_controller.dart';
import 'package:hzn_gyms/src/features/members/presentation/controllers/member_provider.dart';
import 'package:hzn_gyms/src/features/members/presentation/pages/member_detail_page.dart';
import 'package:hzn_gyms/src/features/memberships/domain/member_membership.dart';
import 'package:hzn_gyms/src/features/memberships/presentation/controllers/member_memberships_controller.dart';
import 'package:hzn_gyms/src/features/sales/presentation/controllers/member_sales_provider.dart';
import 'package:hzn_gyms/src/features/settings/domain/branch.dart';
import 'package:hzn_gyms/src/features/settings/presentation/controllers/branches_controller.dart';
import 'package:hzn_gyms/src/features/users/domain/user.dart';
import 'package:hzn_gyms/src/features/users/presentation/controllers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

class _FakeMemberCardsController extends MemberCardsController {
  @override
  Future<List<MemberCard>> build(String memberId) async => const [];
}

class _FakeMemberMembershipsController extends MemberMembershipsController {
  @override
  Future<List<MemberMembership>> build(String memberId) async => const [];
}

class _FakeBranchesController extends BranchesController {
  @override
  Future<List<Branch>> build() async => const [];
}

void main() {
  testWidgets('shows who added the customer', (tester) async {
    final member = buildMember(
      id: 'member-1',
      name: 'Christian Hizon',
      addedBy: 'user-1',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          memberProvider(member.id).overrideWith((ref) async => member),
          userProvider('user-1').overrideWith(
            (ref) async => const User(
              id: 'user-1',
              name: 'Front Desk',
              username: 'frontdesk',
            ),
          ),
          memberCardsControllerProvider.overrideWith(
            _FakeMemberCardsController.new,
          ),
          memberMembershipsControllerProvider.overrideWith(
            _FakeMemberMembershipsController.new,
          ),
          memberCheckInsProvider(member.id).overrideWith((ref) async => []),
          memberSalesProvider(member.id).overrideWith((ref) async => []),
          branchesControllerProvider.overrideWith(_FakeBranchesController.new),
        ],
        child: MaterialApp(
          home: MemberDetailPage(memberId: member.id),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Added by'), findsOneWidget);
    expect(find.text('Front Desk'), findsOneWidget);
  });
}
