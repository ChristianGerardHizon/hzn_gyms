import 'package:kylie_gym/src/core/i18n/strings.g.dart';
import 'package:kylie_gym/src/features/sales/domain/sale_status_filter.dart';
import 'package:kylie_gym/src/features/sales/presentation/controllers/sale_search_controller.dart';
import 'package:kylie_gym/src/features/sales/presentation/widgets/dialogs/sale_search_fields_dialog.dart';
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
    expect(find.byType(SwitchListTile), findsNWidgets(3));
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Paid'), findsOneWidget);
    expect(find.text('Voided'), findsOneWidget);
    expect(find.text('Awaiting Payment'), findsOneWidget);

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
    expect(
      container.read(saleStatusFiltersProvider),
      defaultSaleStatusFilters,
    );
  });

  testWidgets('status switches toggle and Reset restores defaults',
      (tester) async {
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

    await tester.ensureVisible(find.byKey(const ValueKey('status-voided-true')));
    await tester.tap(find.byKey(const ValueKey('status-voided-true')));
    await tester.pumpAndSettle();

    expect(
      container.read(saleStatusFiltersProvider),
      {'paid', 'awaitingPayment'},
    );

    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();

    expect(
      container.read(saleStatusFiltersProvider),
      defaultSaleStatusFilters,
    );
  });
}
