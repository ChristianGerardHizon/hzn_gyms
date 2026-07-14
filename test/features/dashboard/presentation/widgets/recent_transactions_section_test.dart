import 'package:ebe_gym/src/features/dashboard/presentation/controllers/todays_sales_controller.dart';
import 'package:ebe_gym/src/features/dashboard/presentation/widgets/recent_transactions_section.dart';
import 'package:ebe_gym/src/features/pos/domain/sale.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
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
  });
}
