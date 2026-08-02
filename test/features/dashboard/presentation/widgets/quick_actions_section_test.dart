import 'package:ebe_gym/src/features/dashboard/presentation/widgets/quick_actions_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuickActionsSection', () {
    testWidgets('shows Cashier and Walk-in quick actions', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: QuickActionsSection(),
            ),
          ),
        ),
      );

      expect(find.text('Cashier'), findsOneWidget);
      expect(find.text('Walk-in'), findsOneWidget);
      expect(find.text('Check-In'), findsOneWidget);
      expect(find.text('Renew'), findsOneWidget);
      expect(find.text('Search Member'), findsOneWidget);
      expect(find.text('New Member'), findsOneWidget);
    });
  });
}
