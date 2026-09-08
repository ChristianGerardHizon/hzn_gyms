import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/features/sales/presentation/widgets/void_sale_dialog.dart';

void main() {
  testWidgets('requires a reason before void can submit', (tester) async {
    String? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showVoidSaleDialog(context);
              },
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Void Sale?'), findsOneWidget);

    final voidButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Void'),
    );
    expect(voidButton.onPressed, isNull);

    await tester.enterText(find.byType(TextField), 'Duplicate sale');
    await tester.pump();

    await tester.tap(find.widgetWithText(FilledButton, 'Void'));
    await tester.pumpAndSettle();

    expect(result, 'Duplicate sale');
  });

  testWidgets('cancel returns null', (tester) async {
    String? result = 'unset';

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showVoidSaleDialog(context);
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

    expect(result, isNull);
  });
}
