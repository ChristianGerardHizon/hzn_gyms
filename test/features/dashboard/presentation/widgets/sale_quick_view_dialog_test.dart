import 'package:hzn_gyms/src/features/dashboard/presentation/widgets/sale_quick_view_dialog.dart';
import 'package:hzn_gyms/src/features/pos/presentation/payments_controller.dart';
import 'package:hzn_gyms/src/features/sales/presentation/controllers/sale_items_provider.dart';
import 'package:hzn_gyms/src/features/sales/presentation/controllers/sale_provider.dart';
import 'package:hzn_gyms/src/features/users/domain/user.dart';
import 'package:hzn_gyms/src/features/users/presentation/controllers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  group('SaleQuickViewDialog', () {
    testWidgets('shows sold-by account and clickable customer', (tester) async {
      final sale = buildSale(
        id: 'sale-1',
        cashierId: 'user-1',
        customerId: 'member-1',
        customerName: 'Christian Hizon',
        descriptor: 'Regular Rate',
        totalAmount: 1300,
        status: 'completed',
        isPaid: true,
      );

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
                username: 'frontdesk',
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SaleQuickViewDialog(saleId: sale.id, fallbackSale: sale),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Sold by'), findsOneWidget);
      expect(find.text('Front Desk'), findsOneWidget);
      expect(find.text('Christian Hizon'), findsOneWidget);
      expect(find.byIcon(Icons.open_in_new), findsWidgets);
    });

    testWidgets('walk-in customer is not a link', (tester) async {
      final sale = buildSale(
        id: 'sale-2',
        cashierId: 'user-1',
        customerName: 'Walk-in',
        totalAmount: 100,
        status: 'completed',
        isPaid: true,
      );

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
                username: 'frontdesk',
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SaleQuickViewDialog(saleId: sale.id, fallbackSale: sale),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Walk-in'), findsOneWidget);
      // Only the "Show full details" button uses open_in_new for walk-ins.
      expect(find.byIcon(Icons.open_in_new), findsOneWidget);
    });
  });
}
