import 'package:hzn_gyms/src/core/i18n/strings.g.dart';
import 'package:hzn_gyms/src/core/permissions/current_user_permissions.dart';
import 'package:hzn_gyms/src/core/widgets/scope_switcher_bar.dart';
import 'package:hzn_gyms/src/features/organizations/domain/organization.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/current_organization_controller.dart';
import 'package:hzn_gyms/src/features/organizations/presentation/controllers/organizations_controller.dart';
import 'package:hzn_gyms/src/features/settings/domain/branch.dart';
import 'package:hzn_gyms/src/features/settings/presentation/controllers/branches_controller.dart';
import 'package:hzn_gyms/src/features/settings/presentation/controllers/current_branch_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const org = Organization(id: 'org-1', name: 'Kylie Gym', slug: 'kyliegym');
  const branch = Branch(
    id: 'branch-a',
    name: 'Branch A',
    code: 'BRA',
    slug: 'bra',
    address: 'x',
    contactNumber: '1',
  );

  testWidgets('shows org and branch side by side for platform admins', (
    tester,
  ) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          overrides: [
            currentUserPermissionsProvider.overrideWith(
              () => _FakePermissionsController(
                const CurrentUserPermissions(superAdmin: true),
              ),
            ),
            organizationsControllerProvider.overrideWith(
              () => _FakeOrganizationsController(const [org]),
            ),
            currentOrganizationControllerProvider.overrideWith(
              () => _FakeCurrentOrganizationController(org),
            ),
            branchesControllerProvider.overrideWith(
              () => _FakeBranchesController(const [branch]),
            ),
            currentBranchControllerProvider.overrideWith(
              () => _FakeAllBranchesController(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: ScopeSwitcherBar()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kylie Gym'), findsOneWidget);
    expect(find.text('All Branches'), findsOneWidget);
    expect(find.byType(VerticalDivider), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsNWidgets(2));
  });

  testWidgets('shows branch only when user cannot manage organizations', (
    tester,
  ) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          overrides: [
            currentUserPermissionsProvider.overrideWith(
              () => _FakePermissionsController(const CurrentUserPermissions()),
            ),
            branchesControllerProvider.overrideWith(
              () => _FakeBranchesController(const [branch]),
            ),
            currentBranchControllerProvider.overrideWith(
              () => _FakeAllBranchesController(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: ScopeSwitcherBar()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kylie Gym'), findsNothing);
    expect(find.text('All Branches'), findsOneWidget);
    expect(find.byType(VerticalDivider), findsNothing);
  });
}

class _FakePermissionsController extends CurrentUserPermissionsController {
  _FakePermissionsController(this._permissions);

  final CurrentUserPermissions _permissions;

  @override
  Future<CurrentUserPermissions> build() async => _permissions;
}

class _FakeOrganizationsController extends OrganizationsController {
  _FakeOrganizationsController(this._organizations);

  final List<Organization> _organizations;

  @override
  Future<List<Organization>> build() async => _organizations;
}

class _FakeCurrentOrganizationController extends CurrentOrganizationController {
  _FakeCurrentOrganizationController(this._organization);

  final Organization _organization;

  @override
  Future<Organization?> build() async => _organization;
}

class _FakeBranchesController extends BranchesController {
  _FakeBranchesController(this._branches);

  final List<Branch> _branches;

  @override
  Future<List<Branch>> build() async => _branches;
}

class _FakeAllBranchesController extends CurrentBranchController {
  @override
  Future<CurrentBranchSelection> build() async {
    return const CurrentBranchSelection(isAll: true);
  }

  @override
  Future<bool> canSwitchBranch() async => true;

  @override
  Future<bool> canViewAllBranches() async => true;

  @override
  Future<List<String>> switchableBranchIds() async => const ['branch-a'];
}
