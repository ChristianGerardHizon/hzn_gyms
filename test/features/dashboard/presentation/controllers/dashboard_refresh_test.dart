import 'package:ebe_gym/src/features/dashboard/presentation/controllers/active_members_count_controller.dart';
import 'package:ebe_gym/src/features/dashboard/presentation/controllers/dashboard_members_controller.dart';
import 'package:ebe_gym/src/features/dashboard/presentation/controllers/dashboard_refresh.dart';
import 'package:ebe_gym/src/features/dashboard/presentation/controllers/new_members_controller.dart';
import 'package:ebe_gym/src/features/dashboard/presentation/controllers/todays_sales_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

  testWidgets(
    'refreshDashboardAfterMemberChange invalidates membership and sales cards',
    (tester) async {
      var salesBuilds = 0;
      var summaryBuilds = 0;
      var activeBuilds = 0;
      var newMembersBuilds = 0;
      var membersPageBuilds = 0;

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
            activeMembersCountProvider.overrideWith((ref) async {
              activeBuilds++;
              return 0;
            }),
            todaysNewMembersCountProvider.overrideWith((ref) async {
              newMembersBuilds++;
              return 0;
            }),
            dashboardMembersPageProvider.overrideWith((ref, args) async {
              membersPageBuilds++;
              return const DashboardMembersPage(
                items: [],
                totalItems: 0,
                page: 1,
                totalPages: 0,
              );
            }),
          ],
          child: Consumer(
            builder: (context, ref, _) {
              ref.watch(todaySalesProvider);
              ref.watch(todaySalesSummaryProvider);
              ref.watch(activeMembersCountProvider);
              ref.watch(todaysNewMembersCountProvider);
              ref.watch(dashboardMembersPageProvider());
              return MaterialApp(
                home: Scaffold(
                  body: TextButton(
                    onPressed: () => refreshDashboardAfterMemberChange(ref),
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
      expect(activeBuilds, 1);
      expect(newMembersBuilds, 1);
      expect(membersPageBuilds, 1);

      await tester.tap(find.text('Refresh'));
      await tester.pumpAndSettle();

      expect(salesBuilds, 2);
      expect(summaryBuilds, 2);
      expect(activeBuilds, 2);
      expect(newMembersBuilds, 2);
      expect(membersPageBuilds, 2);
    },
  );
}
