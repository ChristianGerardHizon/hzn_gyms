import 'package:hzn_gyms/src/core/packages/app_info/app_info_provider.dart';
import 'package:hzn_gyms/src/core/packages/pocketbase/pb_connectivity_provider.dart';
import 'package:hzn_gyms/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:hzn_gyms/src/features/dashboard/domain/dashboard_greeting.dart';
import 'package:hzn_gyms/src/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../helpers/fixtures.dart';

class _FakePbConnectivity extends PbConnectivity {
  _FakePbConnectivity(this._online);

  final bool _online;

  @override
  Future<bool> build() async => _online;
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
          overrides: [
            currentAuthProvider.overrideWithValue(namedAuth),
            pbConnectivityProvider.overrideWith(
              () => _FakePbConnectivity(true),
            ),
            appInfoProvider.overrideWith(
              (ref) async => PackageInfo(
                appName: 'kylie_gym',
                packageName: 'com.example.kylie_gym',
                version: '1.27.2',
                buildNumber: '42',
              ),
            ),
          ],
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
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    },
  );

  testWidgets('shows Offline when connectivity is down', (tester) async {
    final auth = buildAuthState();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentAuthProvider.overrideWithValue(auth),
          pbConnectivityProvider.overrideWith(
            () => _FakePbConnectivity(false),
          ),
          appInfoProvider.overrideWith(
            (ref) async => PackageInfo(
              appName: 'kylie_gym',
              packageName: 'com.example.kylie_gym',
              version: '1.27.2',
              buildNumber: '42',
            ),
          ),
        ],
        child: const MaterialApp(
          home: Scaffold(body: DashboardHeader()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Offline'), findsOneWidget);
    expect(find.text('v1.27.2+42'), findsOneWidget);
  });
}
