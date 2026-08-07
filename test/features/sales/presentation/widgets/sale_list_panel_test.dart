import 'package:ebe_gym/src/core/foundation/paginated_state.dart';
import 'package:ebe_gym/src/core/i18n/strings.g.dart';
import 'package:ebe_gym/src/core/widgets/branch_code_pill.dart';
import 'package:ebe_gym/src/features/pos/domain/sale.dart';
import 'package:ebe_gym/src/features/sales/presentation/controllers/paginated_sales_controller.dart';
import 'package:ebe_gym/src/features/sales/presentation/widgets/sale_list_panel.dart';
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

class _FakePaginatedSalesController extends PaginatedSalesController {
  @override
  Future<PaginatedState<Sale>> build() async {
    return const PaginatedState(items: [], hasReachedEnd: true);
  }
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

  Future<void> pumpPanel(
    WidgetTester tester, {
    required List<Sale> sales,
    required bool viewingAll,
  }) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          overrides: [
            paginatedSalesControllerProvider.overrideWith(
              () => _FakePaginatedSalesController(),
            ),
            branchesControllerProvider.overrideWith(
              () => _FakeBranchesController(const [branchA, branchB]),
            ),
            viewingAllBranchesProvider.overrideWithValue(viewingAll),
          ],
          child: MaterialApp(
            home: SaleListPanel(
              paginatedState: PaginatedState(
                items: sales,
                totalItems: sales.length,
                totalPages: 1,
                hasReachedEnd: true,
              ),
              selectedId: null,
              onSaleTap: (_) {},
              onRefresh: () async {},
              onLoadMore: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows branch code pills when viewing all branches', (
    tester,
  ) async {
    await pumpPanel(
      tester,
      viewingAll: true,
      sales: [
        buildSale(
          id: 'sale-1',
          receiptNumber: 'S-1',
          branchId: 'branch-a',
          descriptor: 'Sale A',
          totalAmount: 100,
        ),
        buildSale(
          id: 'sale-2',
          receiptNumber: 'S-2',
          branchId: 'branch-b',
          descriptor: 'Sale B',
          totalAmount: 200,
        ),
      ],
    );

    expect(find.byType(BranchCodePill), findsNWidgets(2));
    expect(find.text('BCD'), findsOneWidget);
    expect(find.text('TAL'), findsOneWidget);
    // Leading receipt avatars removed.
    expect(find.byIcon(Icons.receipt), findsNothing);
  });

  testWidgets('hides branch code pills when a single branch is selected', (
    tester,
  ) async {
    await pumpPanel(
      tester,
      viewingAll: false,
      sales: [
        buildSale(
          id: 'sale-1',
          receiptNumber: 'S-1',
          branchId: 'branch-a',
          descriptor: 'Sale A',
          totalAmount: 100,
        ),
      ],
    );

    expect(find.byType(BranchCodePill), findsNothing);
  });
}
