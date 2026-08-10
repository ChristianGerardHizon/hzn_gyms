import 'package:ebe_gym/src/features/dashboard/presentation/widgets/todays_sales_breakdown_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders hero revenue, type cards, and status pills', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TodaysSalesBreakdownHeader(
            revenueLabel: '₱3,000.00',
            transactionCount: 3,
            membershipTotalLabel: '₱3,000.00',
            membershipCount: 3,
            walkInTotalLabel: '₱0.00',
            walkInCount: 0,
            paidCount: 3,
            unpaidCount: 0,
            branchChips: ['BCD · 2', 'TAL · 1'],
          ),
        ),
      ),
    );

    expect(find.text('Revenue'), findsOneWidget);
    expect(find.text('₱3,000.00'), findsNWidgets(2));
    expect(find.text('3 sales'), findsNWidgets(2)); // hero + memberships
    expect(find.text('Memberships'), findsOneWidget);
    expect(find.text('Walk-ins'), findsOneWidget);
    expect(find.text('0 sales'), findsOneWidget);
    expect(find.text('3 Paid'), findsOneWidget);
    expect(find.text('0 Unpaid'), findsOneWidget);
    expect(find.text('BCD · 2'), findsOneWidget);
    expect(find.text('TAL · 1'), findsOneWidget);
  });
}
