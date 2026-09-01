import 'package:kylie_gym/src/core/utils/date_utils.dart';
import 'package:kylie_gym/src/features/memberships/domain/membership.dart';
import 'package:kylie_gym/src/features/memberships/domain/membership_add_on.dart';
import 'package:kylie_gym/src/features/memberships/presentation/controllers/membership_add_ons_controller.dart';
import 'package:kylie_gym/src/features/memberships/presentation/controllers/membership_purchase_catalog_provider.dart';
import 'package:kylie_gym/src/features/memberships/presentation/widgets/purchase_membership_dialog.dart';
import 'package:kylie_gym/src/features/settings/domain/branch.dart';
import 'package:kylie_gym/src/features/settings/presentation/controllers/branches_controller.dart';
import 'package:kylie_gym/src/features/settings/presentation/controllers/current_branch_controller.dart';
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
  group('membershipRenewalSuccessMessage', () {
    test('returns renewed message when online and included in sales', () {
      expect(
        membershipRenewalSuccessMessage(
          queuedOffline: false,
          excludedFromSales: false,
        ),
        'Membership renewed successfully',
      );
    });

    test('returns queued message when offline', () {
      expect(
        membershipRenewalSuccessMessage(
          queuedOffline: true,
          excludedFromSales: false,
        ),
        'Membership renewal queued — will sync when online',
      );
    });

    test('returns queued excluded message when offline and excluded', () {
      expect(
        membershipRenewalSuccessMessage(
          queuedOffline: true,
          excludedFromSales: true,
        ),
        'Membership renewal queued (excluded from sales) — will sync when online',
      );
    });

    test('returns renewed message when excluded from sales but online', () {
      expect(
        membershipRenewalSuccessMessage(
          queuedOffline: false,
          excludedFromSales: true,
        ),
        'Membership renewed successfully',
      );
    });
  });

  group('PurchaseMembershipDialog', () {
    testWidgets('guest mode shows Walk-in title not Cashier', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final walkInPlan = buildMembership(
        name: 'NEW RATE WALK-IN REGULAR',
        durationValue: 1,
        durationUnit: MembershipDurationUnit.days,
        price: 100,
        memberNotRequired: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            effectiveBranchIdForWriteProvider.overrideWithValue('branch-1'),
            currentBranchIdProvider.overrideWithValue('branch-1'),
            branchesControllerProvider.overrideWith(
              () => _FakeBranchesController(const [_testBranch]),
            ),
            membershipPurchaseCatalogProvider(false).overrideWith(
              (ref) async => [walkInPlan],
            ),
            membershipPurchaseCatalogProvider(true).overrideWith(
              (ref) async => [walkInPlan],
            ),
            membershipAddOnsControllerProvider.overrideWith(
              () => _FakeMembershipAddOnsController(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: PurchaseMembershipDialog(guestMode: true)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Walk-in'), findsOneWidget);
      expect(find.text('Cashier'), findsNothing);
      expect(find.text('Day pass — name and plan only'), findsOneWidget);
      expect(find.text('Select a walk-in plan'), findsOneWidget);
    });
  });
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
