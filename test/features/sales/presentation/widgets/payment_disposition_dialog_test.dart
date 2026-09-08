import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/features/sales/presentation/widgets/payment_disposition_dialog.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  testWidgets('Keep unpaid asks for confirmation before returning',
      (tester) async {
    PaymentDisposition? result = PaymentDisposition.recordPayment;

    final sale = buildSale(
      receiptNumber: 'S-250101-9PP8',
      descriptor: 'Walk-in · day pass',
      isPaid: false,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showPaymentDispositionDialog(
                  context,
                  sale: sale,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Sale is unpaid'), findsOneWidget);

    await tester.tap(find.text('Keep unpaid'));
    await tester.pumpAndSettle();

    expect(find.text('Keep sale unpaid?'), findsOneWidget);
    expect(find.text('Sale is unpaid'), findsOneWidget);

    // Cancel confirm — disposition stays open.
    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Keep sale unpaid?'), findsNothing);
    expect(find.text('Sale is unpaid'), findsOneWidget);
    expect(result, PaymentDisposition.recordPayment);

    await tester.tap(find.text('Keep unpaid'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Keep unpaid'));
    await tester.pumpAndSettle();

    expect(result, PaymentDisposition.keepUnpaid);
  });

  testWidgets('keep unpaid confirm cancel returns false', (tester) async {
    bool? result = true;
    final sale = buildSale(isPaid: false);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showKeepUnpaidConfirmDialog(
                  context,
                  sale: sale,
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(result, false);
  });
}
