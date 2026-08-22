import 'package:kylie_gym/src/features/pos/presentation/components/checkout_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CheckoutDialog walk-in hint', () {
    testWidgets('member section explains walk-in when member is optional', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: CheckoutDialog(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Member (Optional)'), findsOneWidget);
      expect(find.text('Leave empty for walk-in customers'), findsOneWidget);
    });
  });
}
