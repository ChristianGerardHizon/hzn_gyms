import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kylie_gym/src/core/permissions/current_user_permissions.dart';
import 'package:kylie_gym/src/features/settings/presentation/widgets/system_nav_panel.dart';
import 'package:kylie_gym/src/features/users/domain/user_role.dart';

class _FixedPermissions extends CurrentUserPermissionsController {
  _FixedPermissions(this._permissions);

  final CurrentUserPermissions _permissions;

  @override
  Future<CurrentUserPermissions> build() async => _permissions;
}

void main() {
  testWidgets(
    'fits all admin modes in a short viewport without overflowing',
    (tester) async {
      // Matches the constrained height that previously overflowed by ~27px.
      await tester.binding.setSurfaceSize(const Size(400, 629));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            currentUserPermissionsProvider.overrideWith(
              () => _FixedPermissions(
                const CurrentUserPermissions(
                  permissions: {
                    Permissions.systemAdmin,
                    Permissions.activityLogView,
                  },
                ),
              ),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Row(
                children: [
                  SystemNavPanel(
                    currentMode: SystemMode.appearance,
                    onModeChanged: (_) {},
                  ),
                  const Expanded(child: SizedBox.expand()),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Categories'), findsOneWidget);
      expect(find.text('Activity Log'), findsOneWidget);
    },
  );

  testWidgets('non-admin sees only Appearance and Camera', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserPermissionsProvider.overrideWith(
            () => _FixedPermissions(CurrentUserPermissions.empty),
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SystemNavPanel(
              currentMode: SystemMode.appearance,
              onModeChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Categories'), findsNothing);
    expect(find.text('Debug'), findsNothing);
  });
}
