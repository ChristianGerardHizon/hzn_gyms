import 'package:hzn_gyms/src/core/widgets/branch_code_pill.dart';
import 'package:hzn_gyms/src/features/dashboard/presentation/controllers/new_members_controller.dart';
import 'package:hzn_gyms/src/features/dashboard/presentation/controllers/todays_sales_controller.dart';
import 'package:hzn_gyms/src/features/dashboard/presentation/widgets/kpi_breakdown_dialogs.dart';
import 'package:hzn_gyms/src/features/members/domain/member.dart';
import 'package:hzn_gyms/src/features/pos/domain/sale.dart';
import 'package:hzn_gyms/src/features/settings/domain/branch.dart';
import 'package:hzn_gyms/src/features/settings/presentation/controllers/branches_controller.dart';
import 'package:hzn_gyms/src/features/settings/presentation/controllers/current_branch_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

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
    slug: 'bcd',
    address: 'x',
    contactNumber: '1',
  );
  const branchB = Branch(
    id: 'branch-b',
    name: 'Talisay Branch',
    code: 'TAL',
    slug: 'tal',
    address: 'y',
    contactNumber: '2',
  );

  final entries = [
    const NewMemberEntry(
      member: Member(id: 'member-1', name: 'Alice', branch: 'branch-a'),
    ),
    const NewMemberEntry(
      member: Member(id: 'member-2', name: 'Bob', branch: 'branch-b'),
    ),
  ];

  Future<void> pumpAndOpenNewMembersDialog(
    WidgetTester tester, {
    required bool viewingAll,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todaysNewMembersListProvider.overrideWith((ref) async => entries),
          branchesControllerProvider.overrideWith(
            () => _FakeBranchesController(const [branchA, branchB]),
          ),
          viewingAllBranchesProvider.overrideWithValue(viewingAll),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showNewMembersBreakdownDialog(context),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'shows a branch code pill per member when viewing all branches',
    (tester) async {
      await pumpAndOpenNewMembersDialog(tester, viewingAll: true);

      final pills = find.byType(BranchCodePill);
      expect(pills, findsNWidgets(2));
      expect(
        find.descendant(of: pills, matching: find.text('BCD')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: pills, matching: find.text('TAL')),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'hides branch code pills when a single branch is selected',
    (tester) async {
      await pumpAndOpenNewMembersDialog(tester, viewingAll: false);

      expect(find.byType(BranchCodePill), findsNothing);
    },
  );

  testWidgets(
    "Today's Sales breakdown uses structured summary header",
    (tester) async {
      final sale = buildSale(
        id: 'sale-1',
        receiptNumber: 'R-1001',
        branchId: branchA.id,
        totalAmount: 1000,
        status: 'completed',
        isPaid: true,
        customerName: 'Christian',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todaySalesProvider.overrideWith(
              (ref) async => <Sale>[sale],
            ),
            todaySalesSummaryProvider.overrideWith(
              (ref) async => const TodaySalesSummary(
                count: 1,
                total: 1000,
                membershipTotal: 1000,
                walkInTotal: 0,
                membershipCount: 1,
                walkInCount: 0,
              ),
            ),
            branchesControllerProvider.overrideWith(
              () => _FakeBranchesController(const [branchA, branchB]),
            ),
            viewingAllBranchesProvider.overrideWithValue(false),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () => showTodaysSalesBreakdownDialog(context),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text("Today's Sales"), findsOneWidget);
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('Memberships'), findsOneWidget);
      expect(find.text('Walk-ins'), findsOneWidget);
      expect(find.text('Transactions'), findsOneWidget);
      expect(find.textContaining('Paid'), findsWidgets);
      expect(find.byType(ErrorWidget), findsNothing);
    },
  );
}
