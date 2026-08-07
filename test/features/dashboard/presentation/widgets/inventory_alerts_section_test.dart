import 'package:ebe_gym/src/core/utils/breakpoints.dart';
import 'package:ebe_gym/src/features/dashboard/domain/inventory_alert.dart';
import 'package:ebe_gym/src/features/dashboard/presentation/controllers/inventory_alerts_controller.dart';
import 'package:ebe_gym/src/features/dashboard/presentation/widgets/inventory_alerts_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  InventoryAlert alert({
    required InventoryAlertType type,
    required String id,
    required String name,
    num? qty,
  }) {
    return InventoryAlert(
      productId: id,
      productName: name,
      alertType: type,
      isLotTracked: false,
      currentQuantity: qty,
    );
  }

  final summary = InventoryAlertsSummary(
    outOfStockAlerts: [
      alert(
        type: InventoryAlertType.outOfStock,
        id: 'p1',
        name: 'blitz 450',
        qty: 0,
      ),
    ],
    lowStockAlerts: [
      alert(
        type: InventoryAlertType.lowStock,
        id: 'p2',
        name: 'blitz 120',
        qty: 5,
      ),
    ],
  );

  Future<void> pumpSection(WidgetTester tester, {required double width}) async {
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(size: Size(width, 900)),
        child: ProviderScope(
          overrides: [
            inventoryAlertsSummaryProvider.overrideWith((ref) async => summary),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: InventoryAlertsSection(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('stacks alert cards on mobile', (tester) async {
    await pumpSection(tester, width: Breakpoints.mobile - 40);

    expect(find.text('Out of Stock'), findsOneWidget);
    expect(find.text('Low Stock'), findsOneWidget);

    final outTop = tester.getTopLeft(find.text('Out of Stock'));
    final lowTop = tester.getTopLeft(find.text('Low Stock'));

    // Stacked: Low Stock below Out of Stock, same column.
    expect(lowTop.dy, greaterThan(outTop.dy));
    expect((lowTop.dx - outTop.dx).abs(), lessThan(8));
  });

  testWidgets('places alert cards side by side on tablet+', (tester) async {
    await pumpSection(tester, width: Breakpoints.mobile + 200);

    expect(find.text('Out of Stock'), findsOneWidget);
    expect(find.text('Low Stock'), findsOneWidget);

    final outTop = tester.getTopLeft(find.text('Out of Stock'));
    final lowTop = tester.getTopLeft(find.text('Low Stock'));

    // Side-by-side: Low Stock to the right, roughly same row.
    expect(lowTop.dx, greaterThan(outTop.dx + 40));
    expect((lowTop.dy - outTop.dy).abs(), lessThan(24));
  });
}
