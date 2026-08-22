import 'package:kylie_gym/src/features/memberships/presentation/widgets/membership_period_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  final dateFormat = DateFormat.yMMMd();
  final defaultStart = DateTime(2026, 8, 9);
  final defaultEnd = DateTime(2026, 9, 9);
  final customStart = DateTime(2026, 8, 15);
  final customEnd = DateTime(2026, 9, 15);

  Future<void> pumpPreview(
    WidgetTester tester, {
    required DateTime startDate,
    required DateTime endDate,
    required bool isDateCustomized,
    bool isStacking = false,
    DateTime? currentMembershipEndDate,
    int bonusDays = 0,
    VoidCallback? onChangeStartDate,
    VoidCallback? onResetToDefault,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MembershipPeriodPreview(
            startDate: startDate,
            endDate: endDate,
            defaultStartDate: defaultStart,
            defaultEndDate: defaultEnd,
            isDateCustomized: isDateCustomized,
            isStacking: isStacking,
            currentMembershipEndDate: currentMembershipEndDate,
            bonusDays: bonusDays,
            onChangeStartDate: onChangeStartDate ?? () {},
            onResetToDefault: onResetToDefault,
          ),
        ),
      ),
    );
  }

  group('MembershipPeriodPreview', () {
    testWidgets('shows start and end without strikethrough by default', (
      tester,
    ) async {
      await pumpPreview(
        tester,
        startDate: defaultStart,
        endDate: defaultEnd,
        isDateCustomized: false,
      );

      expect(find.text('Membership period'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('End'), findsOneWidget);
      expect(find.text(dateFormat.format(defaultStart)), findsOneWidget);
      expect(find.text(dateFormat.format(defaultEnd)), findsOneWidget);
      expect(find.text('Dates changed'), findsNothing);
      expect(find.text('Change'), findsOneWidget);

      final startText = tester.widget<Text>(
        find.text(dateFormat.format(defaultStart)),
      );
      expect(startText.style?.decoration, isNot(TextDecoration.lineThrough));
    });

    testWidgets('strikes out original dates when customized', (tester) async {
      await pumpPreview(
        tester,
        startDate: customStart,
        endDate: customEnd,
        isDateCustomized: true,
      );

      expect(find.text('Dates changed'), findsOneWidget);
      expect(find.text(dateFormat.format(customStart)), findsOneWidget);
      expect(find.text(dateFormat.format(customEnd)), findsOneWidget);

      final struckStart = tester.widget<Text>(
        find.text(dateFormat.format(defaultStart)),
      );
      final struckEnd = tester.widget<Text>(
        find.text(dateFormat.format(defaultEnd)),
      );
      expect(struckStart.style?.decoration, TextDecoration.lineThrough);
      expect(struckEnd.style?.decoration, TextDecoration.lineThrough);

      final newStart = tester.widget<Text>(
        find.text(dateFormat.format(customStart)),
      );
      expect(newStart.style?.decoration, isNot(TextDecoration.lineThrough));
      expect(newStart.style?.fontWeight, FontWeight.w700);
    });

    testWidgets('shows stacking title and current end date', (tester) async {
      final currentEnd = DateTime(2026, 8, 8);
      await pumpPreview(
        tester,
        startDate: defaultStart,
        endDate: defaultEnd,
        isDateCustomized: false,
        isStacking: true,
        currentMembershipEndDate: currentEnd,
      );

      expect(find.text('Starts after current membership'), findsOneWidget);
      expect(
        find.text(
          'Current membership ends ${dateFormat.format(currentEnd)}',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows reset action when customized while stacking', (
      tester,
    ) async {
      var resetCalled = false;
      await pumpPreview(
        tester,
        startDate: customStart,
        endDate: customEnd,
        isDateCustomized: true,
        isStacking: true,
        currentMembershipEndDate: DateTime(2026, 8, 8),
        onResetToDefault: () => resetCalled = true,
      );

      final resetButton = find.text('Use day after current membership');
      expect(resetButton, findsOneWidget);
      await tester.tap(resetButton);
      expect(resetCalled, isTrue);
    });

    testWidgets('shows bonus days note', (tester) async {
      await pumpPreview(
        tester,
        startDate: defaultStart,
        endDate: defaultEnd,
        isDateCustomized: false,
        bonusDays: 2,
      );

      expect(find.text('Includes 2 extra days from add-ons'), findsOneWidget);
    });

    testWidgets('invokes onChangeStartDate when Change is tapped', (
      tester,
    ) async {
      var changeCalled = false;
      await pumpPreview(
        tester,
        startDate: defaultStart,
        endDate: defaultEnd,
        isDateCustomized: false,
        onChangeStartDate: () => changeCalled = true,
      );

      await tester.tap(find.text('Change'));
      expect(changeCalled, isTrue);
    });
  });
}
