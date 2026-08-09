import 'package:ebe_gym/src/core/packages/app_info/app_info_provider.dart';
import 'package:ebe_gym/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:ebe_gym/src/features/dashboard/domain/dashboard_greeting.dart';
import 'package:ebe_gym/src/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  testWidgets('shows greeting as header and app version as subheader', (
    tester,
  ) async {
    final auth = buildAuthState();
    final namedAuth = auth.copyWith(
      user: auth.user.copyWith(name: 'Chris'),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentAuthProvider.overrideWithValue(namedAuth),
          appInfoProvider.overrideWith(
            (ref) async => PackageInfo(
              appName: 'ebe_gym',
              packageName: 'com.example.ebe_gym',
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
    expect(find.text('v1.27.2+42'), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });
}
