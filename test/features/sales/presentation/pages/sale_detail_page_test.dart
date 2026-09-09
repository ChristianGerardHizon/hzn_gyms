import 'package:hzn_gyms/src/core/permissions/current_user_permissions.dart';
import 'package:hzn_gyms/src/core/widgets/branch_code_pill.dart';
import 'package:hzn_gyms/src/features/pos/presentation/payments_controller.dart';
import 'package:hzn_gyms/src/features/sales/presentation/controllers/sale_items_provider.dart';
import 'package:hzn_gyms/src/features/sales/presentation/controllers/sale_provider.dart';
import 'package:hzn_gyms/src/features/sales/presentation/pages/sale_detail_page.dart';
import 'package:hzn_gyms/src/features/settings/domain/branch.dart';
import 'package:hzn_gyms/src/features/settings/presentation/controllers/branches_controller.dart';
import 'package:hzn_gyms/src/features/settings/presentation/controllers/current_branch_controller.dart';
import 'package:hzn_gyms/src/features/users/domain/user.dart';
import 'package:hzn_gyms/src/features/users/presentation/controllers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

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

void main() {
  const branchA = Branch(
    id: 'branch-a',
    name: 'Bacolod Branch',
    code: 'BCD',
    slug: 'bcd',
    address: 'x',
    contactNumber: '1',
  );

  final sale = buildSale(
    id: 'sale-1',
    receiptNumber: 'S-1',
    branchId: 'branch-a',
    cashierId: 'user-1',
    descriptor: 'WATER',
    totalAmount: 100,
    status: 'completed',
    isPaid: true,
    customerId: 'member-1',
    customerName: 'Christian Hizon',
  );

  Future<void> pumpDetail(
    WidgetTester tester, {
    required bool viewingAll,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          saleProvider(sale.id).overrideWith((ref) async => sale),
          saleItemsProvider(sale.id).overrideWith((ref) async => []),
          salePaymentsProvider(sale.id).overrideWith((ref) async => []),
          userProvider('user-1').overrideWith(
            (ref) async => const User(
              id: 'user-1',
              name: 'Front Desk',
              email: 'frontdesk@example.com',
            ),
          ),
          currentUserPermissionsProvider.overrideWith(
            () => _FakeCurrentUserPermissionsController(
              CurrentUserPermissions.empty,
            ),
          ),
          branchesControllerProvider.overrideWith(
            () => _FakeBranchesController(const [branchA]),
          ),
          viewingAllBranchesProvider.overrideWithValue(viewingAll),
        ],
        child: MaterialApp(
          home: SaleDetailPage(saleId: sale.id),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows branch info when viewing all branches', (tester) async {
    await pumpDetail(tester, viewingAll: true);

    expect(find.byType(BranchCodePill), findsOneWidget);
    expect(find.text('BCD'), findsOneWidget);
    expect(find.text('Bacolod Branch'), findsOneWidget);
    expect(find.textContaining('Branch:'), findsNothing);
  });

  testWidgets('hides branch info when a single branch is selected', (
    tester,
  ) async {
    await pumpDetail(tester, viewingAll: false);

    expect(find.byType(BranchCodePill), findsNothing);
    expect(find.text('Bacolod Branch'), findsNothing);
  });

  testWidgets('shows sold-by cashier and clickable customer', (tester) async {
    await pumpDetail(tester, viewingAll: false);

    expect(find.textContaining('Sold by:'), findsOneWidget);
    expect(find.text('Front Desk'), findsOneWidget);
    expect(find.text('Christian Hizon'), findsOneWidget);
    expect(find.byIcon(Icons.open_in_new), findsOneWidget);
  });
}
