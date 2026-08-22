import 'package:kylie_gym/src/core/widgets/branch_code_pill.dart';
import 'package:kylie_gym/src/features/dashboard/presentation/controllers/todays_sales_controller.dart';
import 'package:kylie_gym/src/features/dashboard/presentation/widgets/recent_transactions_section.dart';
import 'package:kylie_gym/src/features/pos/domain/sale.dart';
import 'package:kylie_gym/src/features/settings/domain/branch.dart';
import 'package:kylie_gym/src/features/settings/presentation/controllers/branches_controller.dart';
import 'package:kylie_gym/src/features/settings/presentation/controllers/current_branch_controller.dart';
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
  const branchB = Branch(
    id: 'branch-b',
    name: 'Talisay Branch',
    code: 'TAL',
    address: 'y',
    contactNumber: '2',
  );

  group('RecentTransactionsSection', () {
    testWidgets('View All opens today\'s transactions dialog', (tester) async {
      final sales = <Sale>[
        buildSale(id: 'sale-1', receiptNumber: 'S-1', totalAmount: 150),
        buildSale(id: 'sale-2', receiptNumber: 'S-2', totalAmount: 200),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todaySalesProvider.overrideWith((ref) async => sales),
            todaySalesSummaryProvider.overrideWith(
              (ref) async => const TodaySalesSummary(count: 2, total: 350),
            ),
            branchesControllerProvider.overrideWith(
              () => _FakeBranchesController(const [branchA, branchB]),
            ),
            viewingAllBranchesProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: RecentTransactionsSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      expect(find.text("Today's Transactions"), findsOneWidget);
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('Transactions'), findsOneWidget);
    });

    testWidgets('shows up to 10 preview cards at 200px width', (tester) async {
      final sales = List.generate(
        12,
        (i) => buildSale(
          id: 'sale-$i',
          receiptNumber: 'S-$i',
          totalAmount: 100.0 + i,
          descriptor: 'Txn $i',
        ),
      );

      // Wide enough for all 10 preview cards (200px + 10px gap).
      await tester.binding.setSurfaceSize(const Size(2400, 600));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todaySalesProvider.overrideWith((ref) async => sales),
            branchesControllerProvider.overrideWith(
              () => _FakeBranchesController(const [branchA, branchB]),
            ),
            viewingAllBranchesProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: RecentTransactionsSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Badge shows total sales count, not just preview.
      expect(find.text('12'), findsOneWidget);

      expect(find.text('Txn 0'), findsOneWidget);
      expect(find.text('Txn 9'), findsOneWidget);
      expect(find.text('Txn 10'), findsNothing);

      final cardSizes = tester
          .widgetList<Material>(find.byType(Material))
          .where((m) => m.borderRadius != null)
          .map((m) => tester.getSize(find.byWidget(m)))
          .toList();

      expect(cardSizes, hasLength(10));
      for (final size in cardSizes) {
        expect(size.width, 200.0);
      }
    });

    testWidgets('shows branch code pills when viewing all branches', (
      tester,
    ) async {
      final sales = <Sale>[
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
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todaySalesProvider.overrideWith((ref) async => sales),
            branchesControllerProvider.overrideWith(
              () => _FakeBranchesController(const [branchA, branchB]),
            ),
            viewingAllBranchesProvider.overrideWithValue(true),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: RecentTransactionsSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BranchCodePill), findsNWidgets(2));
      expect(find.text('BCD'), findsOneWidget);
      expect(find.text('TAL'), findsOneWidget);
    });

    testWidgets('hides branch code pills when a single branch is selected', (
      tester,
    ) async {
      final sales = <Sale>[
        buildSale(
          id: 'sale-1',
          receiptNumber: 'S-1',
          branchId: 'branch-a',
          descriptor: 'Sale A',
          totalAmount: 100,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            todaySalesProvider.overrideWith((ref) async => sales),
            branchesControllerProvider.overrideWith(
              () => _FakeBranchesController(const [branchA, branchB]),
            ),
            viewingAllBranchesProvider.overrideWithValue(false),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: RecentTransactionsSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BranchCodePill), findsNothing);
      expect(find.text('BCD'), findsNothing);
    });
  });
}
