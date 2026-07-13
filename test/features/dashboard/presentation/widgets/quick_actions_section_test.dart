import 'package:ebe_gym/src/features/dashboard/presentation/widgets/quick_actions_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuickActionsSection', () {
    testWidgets('shows Walk-in Sale quick action for POS without member', (
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

      expect(find.text('Walk-in Sale'), findsOneWidget);
      expect(find.text('New Sale'), findsNothing);
      expect(find.text('Check-In'), findsOneWidget);
    });
  });
}
