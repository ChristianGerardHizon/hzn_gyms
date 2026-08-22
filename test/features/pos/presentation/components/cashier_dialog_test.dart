import 'package:kylie_gym/src/features/pos/domain/pos_group.dart';
import 'package:kylie_gym/src/features/pos/presentation/cart_controller.dart';
import 'package:kylie_gym/src/features/pos/presentation/components/cashier_dialog.dart';
import 'package:kylie_gym/src/features/pos/presentation/controllers/pos_groups_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestCartController extends CartController {
  @override
  Future<CartState> build() async => const CartState();
}

class _TestPosGroupsController extends PosGroupsController {
  @override
  Future<List<PosGroup>> build() async => const [
        PosGroup(
          id: 'g1',
          name: 'Retail',
          branchId: 'b1',
          sortOrder: 0,
          items: [],
        ),
      ];
}

void main() {
  group('CashierDialog', () {
    testWidgets('shows walk-in cashier chrome without leaving route', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartControllerProvider.overrideWith(_TestCartController.new),
            posGroupsControllerProvider.overrideWith(
              _TestPosGroupsController.new,
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CashierDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Cashier'), findsOneWidget);
      expect(find.text('Member optional at checkout'), findsOneWidget);
      expect(find.byTooltip('Close'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Close'), findsNothing);

      // Cart pane uses Material (not ColoredBox) so ListTile ink is visible.
      final theme = Theme.of(tester.element(find.text('Cashier')));
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Material &&
              widget.color == theme.colorScheme.surfaceContainerLowest,
        ),
        findsWidgets,
      );
    });

    testWidgets('mobile layout shows sticky cart bar instead of side cart', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            cartControllerProvider.overrideWith(_TestCartController.new),
            posGroupsControllerProvider.overrideWith(
              _TestPosGroupsController.new,
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CashierDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Cart is empty'), findsOneWidget);
      expect(find.text('Add products above'), findsOneWidget);
      expect(find.text('Member optional at checkout'), findsOneWidget);
    });
  });
}
