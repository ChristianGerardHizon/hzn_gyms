import 'package:ebe_gym/src/core/i18n/strings.g.dart';
import 'package:ebe_gym/src/core/permissions/current_user_permissions.dart';
import 'package:ebe_gym/src/features/members/data/local/member_local_data_source.dart';
import 'package:ebe_gym/src/features/members/data/repositories/member_repository.dart';
import 'package:ebe_gym/src/features/members/domain/member.dart';
import 'package:ebe_gym/src/features/members/presentation/widgets/member_form_dialog.dart';
import 'package:ebe_gym/src/features/memberships/domain/membership.dart';
import 'package:ebe_gym/src/features/memberships/domain/membership_add_on.dart';
import 'package:ebe_gym/src/features/memberships/presentation/controllers/membership_add_ons_controller.dart';
import 'package:ebe_gym/src/features/memberships/presentation/controllers/membership_purchase_catalog_provider.dart';
import 'package:ebe_gym/src/features/settings/domain/branch.dart';
import 'package:ebe_gym/src/features/settings/presentation/controllers/branches_controller.dart';
import 'package:ebe_gym/src/features/settings/presentation/controllers/current_branch_controller.dart';
import 'package:ebe_gym/src/features/users/domain/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/fixtures.dart';
import '../../../../helpers/mocks.dart';

const _testBranch = Branch(
  id: 'branch-1',
  name: 'Main Branch',
  code: 'MAIN',
  address: '123 Gym St',
  contactNumber: '555-0100',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Member create wizard review sales checkbox', () {
    testWidgets(
      'shows Exclude from sales unchecked by default when permitted',
      (tester) async {
        await _pumpWizard(
          tester,
          plans: [buildMembership(name: 'Monthly')],
          permissions: const CurrentUserPermissions(
            permissions: {Permissions.membershipsExcludeFromSales},
          ),
        );

        await _completeDetailsStep(tester);
        // Skip photo
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();
        // Skip card
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();

        // Select membership plan
        await tester.tap(find.text('Monthly'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(find.text('Exclude from sales'), findsOneWidget);
        expect(
          find.text('Create membership without a sale or payment'),
          findsOneWidget,
        );

        final checkbox = tester.widget<CheckboxListTile>(
          find.byType(CheckboxListTile),
        );
        expect(checkbox.value, isFalse);
        expect(find.text('Save'), findsOneWidget);
        expect(find.text('Save (no sale)'), findsNothing);

        await tester.tap(find.byType(CheckboxListTile));
        await tester.pumpAndSettle();

        expect(
          tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
          isTrue,
        );
        expect(find.text('Save (no sale)'), findsOneWidget);
      },
    );

    testWidgets(
      'hides Exclude from sales without memberships.excludeFromSales',
      (tester) async {
        await _pumpWizard(
          tester,
          plans: [buildMembership(name: 'Monthly')],
          permissions: const CurrentUserPermissions(
            permissions: {Permissions.membershipsCreate},
          ),
        );

        await _completeDetailsStep(tester);
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Monthly'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(find.text('Exclude from sales'), findsNothing);
        expect(find.text('Save'), findsOneWidget);
        expect(find.text('Save (no sale)'), findsNothing);
      },
    );

    testWidgets(
      'hides Exclude from sales when no membership is selected',
      (tester) async {
        await _pumpWizard(
          tester,
          plans: [buildMembership(name: 'Monthly')],
          permissions: const CurrentUserPermissions(
            permissions: {Permissions.membershipsExcludeFromSales},
          ),
        );

        await _completeDetailsStep(tester);
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Skip'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        expect(find.text('Exclude from sales'), findsNothing);
        expect(find.text('No membership selected'), findsOneWidget);
      },
    );
  });
}

Future<void> _pumpWizard(
  WidgetTester tester, {
  required List<Membership> plans,
  required CurrentUserPermissions permissions,
}) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final local = MockMemberLocalDataSource();
  final repo = MockMemberRepository();
  when(
    () => local.searchQuick(
      any(),
      fields: any(named: 'fields'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) async => <Member>[]);
  when(
    () => repo.searchQuick(
      any(),
      fields: any(named: 'fields'),
      limit: any(named: 'limit'),
    ),
  ).thenAnswer((_) async => right(<Member>[]));

  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          effectiveBranchIdForWriteProvider.overrideWithValue('branch-1'),
          currentBranchIdProvider.overrideWithValue('branch-1'),
          currentUserPermissionsProvider.overrideWith(
            () => _FakeCurrentUserPermissionsController(permissions),
          ),
          memberLocalDataSourceProvider.overrideWithValue(local),
          memberRepositoryProvider.overrideWithValue(repo),
          branchesControllerProvider.overrideWith(
            () => _FakeBranchesController(const [_testBranch]),
          ),
          membershipPurchaseCatalogProvider(false).overrideWith(
            (ref) async => plans,
          ),
          membershipPurchaseCatalogProvider(true).overrideWith(
            (ref) async => plans,
          ),
          membershipAddOnsControllerProvider.overrideWith(
            () => _FakeMembershipAddOnsController(),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: MemberFormDialog(),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _completeDetailsStep(WidgetTester tester) async {
  final fields = find.byType(FormBuilderTextField);
  await tester.enterText(fields.at(0), 'Jane Doe');
  await tester.enterText(fields.at(1), '09171234567');
  await tester.pumpAndSettle();
  await tester.tap(find.text('Next'));
  await tester.pumpAndSettle();
}

class _FakeCurrentUserPermissionsController
    extends CurrentUserPermissionsController {
  _FakeCurrentUserPermissionsController(this._permissions);

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

class _FakeMembershipAddOnsController extends MembershipAddOnsController {
  @override
  Future<List<MembershipAddOn>> build(String membershipId) async => const [];
}
