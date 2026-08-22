import 'package:kylie_gym/src/features/reports/presentation/widgets/report_kpi_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders title, value, and subtitle', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReportKpiCard(
            title: 'Memberships',
            value: '₱1,000.00',
            icon: Icons.card_membership_outlined,
            color: Colors.purple,
            subtitle: 'Membership line revenue',
          ),
        ),
      ),
    );

    expect(find.text('MEMBERSHIPS'), findsOneWidget);
    expect(find.text('₱1,000.00'), findsOneWidget);
    expect(find.text('Membership line revenue'), findsOneWidget);
  });

  testWidgets('compact card uses denser padding than default', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ReportKpiCard(
                key: Key('default'),
                title: 'Total Revenue',
                value: '₱100.00',
                icon: Icons.attach_money,
                color: Colors.green,
              ),
              ReportKpiCard(
                key: Key('compact'),
                title: 'Total Revenue',
                value: '₱100.00',
                icon: Icons.attach_money,
                color: Colors.green,
                compact: true,
              ),
            ],
          ),
        ),
      ),
    );

    Container contentContainer(Key key) {
      return tester.widget<Container>(
        find.descendant(
          of: find.byKey(key),
          matching: find.byWidgetPredicate(
            (w) =>
                w is Container &&
                (w.padding == const EdgeInsets.all(14) ||
                    w.padding == const EdgeInsets.all(10)),
          ),
        ),
      );
    }

    expect(
      contentContainer(const Key('default')).padding,
      const EdgeInsets.all(14),
    );
    expect(
      contentContainer(const Key('compact')).padding,
      const EdgeInsets.all(10),
    );
  });

  testWidgets('featured card still renders value text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ReportKpiCard(
            title: 'Walk-ins',
            value: '₱900.00',
            icon: Icons.directions_walk_outlined,
            color: Colors.indigo,
            featured: true,
          ),
        ),
      ),
    );

    expect(find.text('WALK-INS'), findsOneWidget);
    expect(find.text('₱900.00'), findsOneWidget);
  });

  testWidgets('onTap is invoked when card is tapped', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ReportKpiCard(
            title: 'Memberships',
            value: '₱1,000.00',
            icon: Icons.card_membership_outlined,
            color: Colors.purple,
            featured: true,
            onTap: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ReportKpiCard));
    await tester.pump();
    expect(tapped, isTrue);
  });
}
