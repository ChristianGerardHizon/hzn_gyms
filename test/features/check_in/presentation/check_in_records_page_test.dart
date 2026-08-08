import 'package:ebe_gym/src/core/widgets/branch_code_pill.dart';
import 'package:ebe_gym/src/features/check_in/domain/check_in.dart';
import 'package:ebe_gym/src/features/check_in/presentation/controllers/check_in_records_controller.dart';
import 'package:ebe_gym/src/features/check_in/presentation/pages/check_in_records_page.dart';
import 'package:ebe_gym/src/features/members/presentation/controllers/member_provider.dart';
import 'package:ebe_gym/src/features/settings/domain/branch.dart';
import 'package:ebe_gym/src/features/settings/presentation/controllers/branches_controller.dart';
import 'package:ebe_gym/src/features/settings/presentation/controllers/current_branch_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fixtures.dart';

class _FakeCheckInRecordsController extends CheckInRecordsController {
  _FakeCheckInRecordsController(this._checkIns);

  final List<CheckIn> _checkIns;

  @override
  Future<List<CheckIn>> build() async => _checkIns;
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

  Future<void> pumpPage(
    WidgetTester tester, {
    required List<CheckIn> checkIns,
    required bool viewingAll,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          checkInRecordsControllerProvider.overrideWith(
            () => _FakeCheckInRecordsController(checkIns),
          ),
          branchesControllerProvider.overrideWith(
            () => _FakeBranchesController(const [branchA, branchB]),
          ),
          viewingAllBranchesProvider.overrideWithValue(viewingAll),
          for (final checkIn in checkIns)
            memberProvider(checkIn.memberId).overrideWith(
              (ref) async => buildMember(
                id: checkIn.memberId,
                name: checkIn.memberName ?? 'Jane Doe',
              ),
            ),
        ],
        child: const MaterialApp(home: CheckInRecordsPage()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows branch code pills when viewing all branches', (
    tester,
  ) async {
    await pumpPage(
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
    await pumpPage(
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
}
