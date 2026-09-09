import 'package:hzn_gyms/src/core/foundation/paginated_state.dart';
import 'package:hzn_gyms/src/core/i18n/strings.g.dart';
import 'package:hzn_gyms/src/core/widgets/branch_code_pill.dart';
import 'package:hzn_gyms/src/features/pos/domain/sale.dart';
import 'package:hzn_gyms/src/features/sales/presentation/controllers/paginated_sales_controller.dart';
import 'package:hzn_gyms/src/features/sales/presentation/widgets/sale_list_panel.dart';
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
          created: DateTime(2026, 7, 14),
        ),
        buildSale(
          id: 'sale-2',
          receiptNumber: 'S-2',
          branchId: 'branch-b',
          descriptor: 'Sale B',
          totalAmount: 200,
          created: DateTime(2026, 7, 14),
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
          created: DateTime(2026, 7, 14),
        ),
      ],
    );

    expect(find.byType(BranchCodePill), findsNothing);
  });

  testWidgets('subtitle shows receipt and date without Paid label', (
    tester,
  ) async {
    await pumpPanel(
      tester,
      viewingAll: false,
      sales: [
        buildSale(
          id: 'sale-1',
          receiptNumber: 'S-250101-9PP8',
          branchId: 'branch-a',
          descriptor: 'Walk-in · blitz 450',
          totalAmount: 450,
          isPaid: true,
          status: 'completed',
          created: DateTime(2026, 7, 14),
        ),
      ],
    );

    expect(find.text('Walk-in · blitz 450'), findsOneWidget);
    expect(find.text('#9PP8 · Jul 14, 2026'), findsOneWidget);
    expect(find.textContaining('450'), findsWidgets);
    expect(find.text('Paid'), findsNothing);
    expect(find.textContaining('Unpaid'), findsNothing);
  });
}
