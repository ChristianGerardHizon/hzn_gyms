import 'package:ebe_gym/src/core/i18n/strings.g.dart';
import 'package:ebe_gym/src/core/widgets/branch_code_pill.dart';
import 'package:ebe_gym/src/features/sales/presentation/widgets/sale_list_tile.dart';
import 'package:ebe_gym/src/features/sales/presentation/widgets/sale_status_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  final dateFormat = DateFormat('MMM dd, yyyy');

  group('SaleListTile.buildSubtitle', () {
    test('with descriptor uses short receipt and date', () {
      final sale = buildSale(
        receiptNumber: 'S-250101-9PP8',
        descriptor: 'Walk-in · blitz 450',
        customerName: 'Someone',
        isPaid: true,
        created: DateTime(2026, 7, 14, 14, 30),
      );

      expect(
        SaleListTile.buildSubtitle(sale, dateFormat),
        '#9PP8 · Jul 14, 2026',
      );
    });

    test('without descriptor uses customer and date', () {
      final sale = buildSale(
        receiptNumber: 'S-250101-ABCD',
        customerName: 'Juan',
        created: DateTime(2026, 7, 14),
      );

      expect(
        SaleListTile.buildSubtitle(sale, dateFormat),
        'Juan · Jul 14, 2026',
      );
    });

    test('omits Paid/Unpaid from subtitle', () {
      final paid = buildSale(
        descriptor: 'WATER',
        isPaid: true,
        created: DateTime(2026, 1, 1),
      );
      final unpaid = buildSale(
        descriptor: 'WATER',
        isPaid: false,
        created: DateTime(2026, 1, 1),
      );

      expect(SaleListTile.buildSubtitle(paid, dateFormat), isNot(contains('Paid')));
      expect(
        SaleListTile.buildSubtitle(unpaid, dateFormat),
        isNot(contains('Unpaid')),
      );
    });
  });

  testWidgets('renders title, amount, status, and optional branch pill', (
    tester,
  ) async {
    final sale = buildSale(
      descriptor: 'Sale A',
      receiptNumber: 'S-1-WXYZ',
      totalAmount: 450,
      status: 'completed',
      created: DateTime(2026, 7, 14),
    );

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: SaleListTile(
              sale: sale,
              onTap: () {},
              dateFormat: dateFormat,
              branchPill: const BranchCodePill(label: 'BCD', dense: true),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Sale A'), findsOneWidget);
    expect(find.text('#WXYZ · Jul 14, 2026'), findsOneWidget);
    expect(find.textContaining('450'), findsOneWidget);
    expect(find.text('BCD'), findsOneWidget);
    expect(find.byType(SaleStatusChip), findsOneWidget);
    expect(find.text('Paid'), findsNothing);
  });

  testWidgets('shows full list title in tooltip', (tester) async {
    const longTitle = 'Walk-in - blitz 450 membership day pass';
    final sale = buildSale(
      descriptor: longTitle,
      receiptNumber: 'S-250101-9PP8',
      totalAmount: 450,
      status: 'completed',
      created: DateTime(2026, 8, 7),
    );

    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 280,
              child: SaleListTile(
                sale: sale,
                onTap: () {},
                dateFormat: dateFormat,
              ),
            ),
          ),
        ),
      ),
    );

    final tooltip = tester.widget<Tooltip>(
      find.ancestor(
        of: find.textContaining('Walk-in'),
        matching: find.byType(Tooltip),
      ),
    );
    expect(tooltip.message, longTitle);
  });
}
