import 'package:hzn_gyms/src/core/i18n/strings.g.dart';
import 'package:hzn_gyms/src/core/widgets/branch_switcher.dart';
import 'package:hzn_gyms/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hzn_gyms/src/features/settings/domain/branch.dart';
import 'package:hzn_gyms/src/features/settings/presentation/controllers/branches_controller.dart';
import 'package:hzn_gyms/src/features/settings/presentation/controllers/current_branch_controller.dart';
import 'package:hzn_gyms/src/features/users/domain/user.dart' as users;
import 'package:hzn_gyms/src/features/users/domain/user_role.dart';
import 'package:hzn_gyms/src/features/users/presentation/controllers/user_provider.dart';
import 'package:hzn_gyms/src/features/users/presentation/controllers/user_role_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';

void main() {
  testWidgets('shows branch dropdown when admin views all branches', (
    tester,
  ) async {
    const branchA = Branch(
      id: 'branch-a',
      name: 'Branch A',
      code: 'BRA',
      address: 'x',
      contactNumber: '1',
    );
    const branchB = Branch(
      id: 'branch-b',
      name: 'Branch B',
      code: 'BRB',
      address: 'y',
      contactNumber: '2',
    );

    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          overrides: [
            currentAuthProvider.overrideWith(
              (ref) => buildAuthState().copyWith(
                user: buildAuthState().user.copyWith(
                      id: 'admin-1',
                      branch: 'branch-a',
                      allowedBranches: const ['branch-a', 'branch-b'],
                    ),
              ),
            ),
            userProvider('admin-1').overrideWith(
              (ref) async => users.User(
                id: 'admin-1',
                name: 'Admin',
                username: 'admin',
                verified: true,
                roleId: 'role-admin',
              ),
            ),
            userRoleProvider('role-admin').overrideWith(
              (ref) async => const UserRole(
                id: 'role-admin',
                name: 'Admin',
                permissions: [Permissions.systemAdmin],
              ),
            ),
            branchesControllerProvider.overrideWith(
              () => _FakeBranchesController(const [branchA, branchB]),
            ),
            currentBranchControllerProvider.overrideWith(
              () => _AllBranchesSelectionController(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: BranchSwitcher(compact: true)),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(DropdownButton<String>), findsOneWidget);
    expect(find.text('All Branches'), findsOneWidget);
    expect(find.text('No Branch'), findsNothing);
  });
}

class _FakeBranchesController extends BranchesController {
  _FakeBranchesController(this._branches);

  final List<Branch> _branches;

  @override
  Future<List<Branch>> build() async => _branches;
}

class _AllBranchesSelectionController extends CurrentBranchController {
  @override
  Future<CurrentBranchSelection> build() async {
    return const CurrentBranchSelection(isAll: true);
  }

  @override
  Future<bool> canSwitchBranch() async => true;

  @override
  Future<bool> canViewAllBranches() async => true;

  @override
  Future<List<String>> switchableBranchIds() async =>
      const ['branch-a', 'branch-b'];
}
