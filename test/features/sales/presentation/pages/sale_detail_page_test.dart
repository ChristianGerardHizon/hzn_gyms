import 'package:ebe_gym/src/core/permissions/current_user_permissions.dart';
import 'package:ebe_gym/src/core/widgets/branch_code_pill.dart';
import 'package:ebe_gym/src/features/pos/domain/sale.dart';
import 'package:ebe_gym/src/features/pos/presentation/payments_controller.dart';
import 'package:ebe_gym/src/features/sales/presentation/controllers/sale_items_provider.dart';
import 'package:ebe_gym/src/features/sales/presentation/controllers/sale_provider.dart';
import 'package:ebe_gym/src/features/sales/presentation/pages/sale_detail_page.dart';
import 'package:ebe_gym/src/features/settings/domain/branch.dart';
import 'package:ebe_gym/src/features/settings/presentation/controllers/branches_controller.dart';
import 'package:ebe_gym/src/features/settings/presentation/controllers/current_branch_controller.dart';
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
    address: 'x',
    contactNumber: '1',
  );

  final sale = buildSale(
    id: 'sale-1',
    receiptNumber: 'S-1',
    branchId: 'branch-a',
    descriptor: 'WATER',
    totalAmount: 100,
    status: 'completed',
    isPaid: true,
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
          currentUserPermissionsProvider.overrideWith(
            (ref) async => CurrentUserPermissions.empty,
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
}
