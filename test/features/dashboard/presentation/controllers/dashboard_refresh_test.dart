import 'package:ebe_gym/src/features/dashboard/presentation/controllers/todays_sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ebe_gym/src/features/dashboard/presentation/controllers/dashboard_refresh.dart';

void main() {
  testWidgets('refreshTodaysSales invalidates today sales providers', (
    tester,
  ) async {
    var salesBuilds = 0;
    var summaryBuilds = 0;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todaySalesProvider.overrideWith((ref) async {
            salesBuilds++;
            return const [];
          }),
          todaySalesSummaryProvider.overrideWith((ref) async {
            summaryBuilds++;
            return const TodaySalesSummary(count: 0, total: 0);
          }),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            ref.watch(todaySalesProvider);
            ref.watch(todaySalesSummaryProvider);
            return MaterialApp(
              home: Scaffold(
                body: TextButton(
                  onPressed: () => refreshTodaysSales(ref),
                  child: const Text('Refresh'),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(salesBuilds, 1);
    expect(summaryBuilds, 1);

    await tester.tap(find.text('Refresh'));
    await tester.pumpAndSettle();

    expect(salesBuilds, 2);
    expect(summaryBuilds, 2);
  });
}
