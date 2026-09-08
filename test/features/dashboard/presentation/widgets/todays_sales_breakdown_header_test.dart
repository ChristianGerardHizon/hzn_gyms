import 'package:hzn_gyms/src/features/dashboard/presentation/widgets/todays_sales_breakdown_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders hero revenue, type cards, methods, and status pills', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: TodaysSalesBreakdownHeader(
              revenueLabel: '₱3,000.00',
              transactionCount: 3,
              membershipTotalLabel: '₱3,000.00',
              membershipCount: 3,
              walkInTotalLabel: '₱0.00',
              walkInCount: 0,
              productTotalLabel: '₱250.00',
              productCount: 2,
              paymentMethodTotalLabels: {
                'cash': '₱2,000.00',
                'card': '₱1,000.00',
              },
              paymentMethodCounts: {
                'cash': 2,
                'card': 1,
              },
              paidCount: 3,
              unpaidCount: 0,
              branchChips: ['BCD · 2', 'TAL · 1'],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Revenue'), findsOneWidget);
    expect(find.text('₱3,000.00'), findsNWidgets(2));
    expect(find.text('3 sales'), findsNWidgets(2)); // hero + memberships
    expect(find.text('Memberships'), findsOneWidget);
    expect(find.text('Walk-ins'), findsOneWidget);
    expect(find.text('Products'), findsOneWidget);
    expect(find.text('₱250.00'), findsOneWidget);
    expect(find.text('2 sales'), findsNWidgets(2)); // products + cash
    expect(find.text('0 sales'), findsNWidgets(3)); // walk-ins + bank + check
    expect(find.text('Cash'), findsOneWidget);
    expect(find.text('GCash'), findsOneWidget);
    expect(find.text('Bank Transfer'), findsOneWidget);
    expect(find.text('Check'), findsOneWidget);
    expect(find.text('₱2,000.00'), findsOneWidget);
    expect(find.text('₱1,000.00'), findsOneWidget);
    expect(find.text('1 sale'), findsOneWidget); // GCash
    expect(find.text('3 Paid'), findsOneWidget);
    expect(find.text('0 Unpaid'), findsOneWidget);
    expect(find.text('BCD · 2'), findsOneWidget);
    expect(find.text('TAL · 1'), findsOneWidget);
  });
}
