import 'package:ebe_gym/src/core/widgets/branch_code_pill.dart';
import 'package:ebe_gym/src/features/dashboard/domain/todays_sales_summary.dart';
import 'package:ebe_gym/src/features/dashboard/presentation/controllers/active_members_count_controller.dart';
import 'package:ebe_gym/src/features/dashboard/presentation/controllers/new_members_controller.dart';
import 'package:ebe_gym/src/features/dashboard/presentation/controllers/todays_checkins_controller.dart';
import 'package:ebe_gym/src/features/dashboard/presentation/controllers/todays_sales_controller.dart';
import 'package:ebe_gym/src/features/dashboard/presentation/widgets/kpi_summary_section.dart';
import 'package:ebe_gym/src/features/settings/presentation/controllers/current_branch_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ProviderScope scope({required bool viewingAll, required Widget child}) {
    return ProviderScope(
      overrides: [
        todaySalesSummaryProvider.overrideWith(
          (ref) async => const TodaySalesSummary(
            count: 7,
            total: 1000.5,
            byBranch: [
              TodaysSalesBranchRow(
                branchId: 'branch-a',
                transactionCount: 2,
                totalRevenue: 200,
              ),
              TodaysSalesBranchRow(
                branchId: 'branch-b',
                transactionCount: 5,
                totalRevenue: 800.5,
              ),
            ],
          ),
        ),
        todaysCheckInsCountProvider.overrideWith((ref) async => 4),
        activeMembersCountProvider.overrideWith((ref) async => 9),
        todaysNewMembersCountProvider.overrideWith((ref) async => 3),
        viewingAllBranchesProvider.overrideWithValue(viewingAll),
      ],
      child: child,
    );
  }

  testWidgets('KPI cards omit branch pills even when viewing all branches', (
    tester,
  ) async {
    await tester.pumpWidget(
      scope(
        viewingAll: true,
        child: const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: KpiSummarySection()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text("Today's Sales"), findsOneWidget);
    expect(find.text("Today's Check-ins"), findsOneWidget);
    expect(find.text('Active Members'), findsOneWidget);
    expect(find.text('New Members'), findsOneWidget);
    expect(find.byType(BranchCodePill), findsNothing);
    expect(find.text('BCD 2'), findsNothing);
    expect(find.text('TAL 5'), findsNothing);
  });
}
