import 'package:ebe_gym/src/features/pos/domain/pos_group.dart';
import 'package:ebe_gym/src/features/pos/presentation/cart_controller.dart';
import 'package:ebe_gym/src/features/pos/presentation/components/cashier_dialog.dart';
import 'package:ebe_gym/src/features/pos/presentation/controllers/pos_groups_controller.dart';
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

      expect(find.text('Walk-in Sale'), findsOneWidget);
      expect(find.text('Member optional at checkout'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
    });
  });
}
