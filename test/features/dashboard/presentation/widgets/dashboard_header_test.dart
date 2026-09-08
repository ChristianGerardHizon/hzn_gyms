import 'package:hzn_gyms/src/core/foundation/paginated_state.dart';
import 'package:hzn_gyms/src/core/packages/app_info/app_info_provider.dart';
import 'package:hzn_gyms/src/core/packages/pocketbase/pb_connectivity_provider.dart';
import 'package:hzn_gyms/src/features/activity_log/domain/activity_log.dart';
import 'package:hzn_gyms/src/features/activity_log/presentation/controllers/todays_activity_logs_controller.dart';
import 'package:hzn_gyms/src/features/auth/domain/auth_state.dart';
import 'package:hzn_gyms/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hzn_gyms/src/features/dashboard/domain/dashboard_greeting.dart';
import 'package:hzn_gyms/src/features/dashboard/domain/inventory_alert.dart';
import 'package:hzn_gyms/src/features/dashboard/presentation/controllers/active_members_count_controller.dart';
import 'package:hzn_gyms/src/features/dashboard/presentation/controllers/expiring_memberships_controller.dart';
import 'package:hzn_gyms/src/features/dashboard/presentation/controllers/inventory_alerts_controller.dart';
import 'package:hzn_gyms/src/features/dashboard/presentation/controllers/new_members_controller.dart';
import 'package:hzn_gyms/src/features/dashboard/presentation/controllers/todays_checkins_controller.dart';
import 'package:hzn_gyms/src/features/dashboard/presentation/controllers/todays_sales_controller.dart';
import 'package:hzn_gyms/src/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod/misc.dart' show Override;

import '../../../../helpers/fixtures.dart';

class _FakePbConnectivity extends PbConnectivity {
  _FakePbConnectivity(this._online);

  final bool _online;

  @override
  Future<bool> build() async => _online;
}

List<Override> _headerOverrides({
  required AuthState auth,
  required bool online,
  Duration unpaidDelay = Duration.zero,
}) {
  return [
    currentAuthProvider.overrideWithValue(auth),
    pbConnectivityProvider.overrideWith(() => _FakePbConnectivity(online)),
    appInfoProvider.overrideWith(
      (ref) async => PackageInfo(
        appName: 'hzn_gyms',
        packageName: 'com.example.hzn_gyms',
        version: '1.27.2',
        buildNumber: '42',
      ),
    ),
    todaySalesSummaryProvider.overrideWith(
      (ref) async => const TodaySalesSummary(count: 0, total: 0),
    ),
    todaySalesProvider.overrideWith((ref) async => const []),
    todaysCheckInsCountProvider.overrideWith((ref) async => 0),
    activeMembersCountProvider.overrideWith((ref) async => 0),
    todaysNewMembersCountProvider.overrideWith((ref) async => 0),
    inventoryAlertsSummaryProvider.overrideWith(
      (ref) async => const InventoryAlertsSummary(),
    ),
    todayUnpaidSalesProvider.overrideWith((ref) async {
      if (unpaidDelay > Duration.zero) {
        await Future<void>.delayed(unpaidDelay);
      }
      return const [];
    }),
    expiringMembershipsProvider.overrideWith((ref) async => const []),
    todaysActivityLogsControllerProvider.overrideWith(
      () => _EmptyTodaysActivityLogs(),
    ),
  ];
}

class _EmptyTodaysActivityLogs extends TodaysActivityLogsController {
  @override
  Future<PaginatedState<ActivityLog>> build() async {
    return const PaginatedState(items: [], hasReachedEnd: true);
  }
}

void main() {
  testWidgets(
    'shows greeting, connectivity status, and smaller app version',
    (tester) async {
      final auth = buildAuthState();
      final namedAuth = auth.copyWith(
        user: auth.user.copyWith(name: 'Chris'),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: _headerOverrides(auth: namedAuth, online: true),
          child: const MaterialApp(
            home: Scaffold(body: DashboardHeader()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('dashboard'), findsNothing);
      expect(
        find.text(
          dashboardGreeting(
            dateTime: DateTime.now(),
            userName: 'Chris',
          ),
        ),
        findsOneWidget,
      );
      expect(find.text('Online'), findsOneWidget);
      expect(find.text('v1.27.2+42'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    },
  );

  testWidgets('shows offline when connectivity is down', (tester) async {
    final auth = buildAuthState();

    await tester.pumpWidget(
      ProviderScope(
        overrides: _headerOverrides(auth: auth, online: false),
        child: const MaterialApp(
          home: Scaffold(body: DashboardHeader()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Offline'), findsOneWidget);
    expect(find.text('v1.27.2+42'), findsOneWidget);
  });

  testWidgets('refresh button shows refreshing then done', (tester) async {
    final auth = buildAuthState();

    await tester.pumpWidget(
      ProviderScope(
        overrides: _headerOverrides(
          auth: auth,
          online: true,
          unpaidDelay: const Duration(milliseconds: 200),
        ),
        child: const MaterialApp(
          home: Scaffold(body: DashboardHeader()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Refresh'));
    await tester.pump();
    expect(find.text('Refreshing…'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Done'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1100));
    expect(find.text('Refresh'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
}
