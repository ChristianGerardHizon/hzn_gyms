import 'package:kylie_gym/src/core/permissions/current_user_permissions.dart';
import 'package:kylie_gym/src/features/dashboard/presentation/widgets/quick_actions_section.dart';
import 'package:kylie_gym/src/features/users/domain/user_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FixedPermissions extends CurrentUserPermissionsController {
  _FixedPermissions(this._permissions);

  final CurrentUserPermissions _permissions;

  @override
  Future<CurrentUserPermissions> build() async => _permissions;
}

void main() {
  group('QuickActionsSection', () {
    Future<void> pumpSection(
      WidgetTester tester, {
      CurrentUserPermissions permissions = CurrentUserPermissions.empty,
    }) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserPermissionsProvider.overrideWith(
              () => _FixedPermissions(permissions),
            ),
          ],
          child: const MaterialApp(home: Scaffold(body: QuickActionsSection())),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('shows Cashier and Walk-in quick actions', (tester) async {
      await pumpSection(tester);

      expect(find.text('Cashier'), findsOneWidget);
      expect(find.text('Walk-in'), findsOneWidget);
      expect(find.text('Check-In'), findsOneWidget);
      expect(find.text('Renew'), findsOneWidget);
      expect(find.text('Search Member'), findsOneWidget);
      expect(find.text('New Member'), findsOneWidget);
      expect(find.text("Today's Logs"), findsNothing);
    });

    testWidgets("hides Today's Logs for staff without activityLog.view", (
      tester,
    ) async {
      await pumpSection(
        tester,
        permissions: const CurrentUserPermissions(
          permissions: {Permissions.membersView},
        ),
      );

      expect(find.text("Today's Logs"), findsNothing);
    });

    testWidgets("shows Today's Logs for admins", (tester) async {
      await pumpSection(
        tester,
        permissions: const CurrentUserPermissions(isAdmin: true),
      );

      expect(find.text("Today's Logs"), findsOneWidget);
    });

    testWidgets("shows Today's Logs for staff with activityLog.view", (
      tester,
    ) async {
      await pumpSection(
        tester,
        permissions: const CurrentUserPermissions(
          permissions: {Permissions.activityLogView},
        ),
      );

      expect(find.text("Today's Logs"), findsOneWidget);
    });
  });
}
