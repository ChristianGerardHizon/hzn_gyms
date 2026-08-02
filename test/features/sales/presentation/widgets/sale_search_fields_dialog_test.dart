import 'package:ebe_gym/src/core/i18n/strings.g.dart';
import 'package:ebe_gym/src/features/sales/presentation/controllers/sale_search_controller.dart';
import 'package:ebe_gym/src/features/sales/presentation/widgets/dialogs/sale_search_fields_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Reset restores default search field checkboxes', (tester) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return TextButton(
                    onPressed: () {
                      showDialog<void>(
                        context: context,
                        builder: (context) => const Dialog(
                          child: SaleSearchFieldsDialog(),
                        ),
                      );
                    },
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(SaleSearchFieldsDialog)),
    );
    container.read(saleSearchFieldsProvider.notifier).toggleField('paymentRef');
    await tester.pumpAndSettle();

    expect(find.byType(CheckboxListTile), findsNWidgets(5));
    final paymentRefTile = tester.widget<CheckboxListTile>(
      find.byKey(const ValueKey('paymentRef-true')),
    );
    expect(paymentRefTile.value, isTrue);

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    final resetPaymentRefTile = tester.widget<CheckboxListTile>(
      find.byKey(const ValueKey('paymentRef-false')),
    );
    expect(resetPaymentRefTile.value, isFalse);
    expect(
      container.read(saleSearchFieldsProvider),
      defaultSaleSearchFields,
    );
  });
}
