import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/core/navigation/app_nav_destination.dart';
import 'package:hzn_gyms/src/core/permissions/current_user_permissions.dart';
import 'package:hzn_gyms/src/core/routing/routes/platform.routes.dart';
import 'package:hzn_gyms/src/features/users/domain/user_role.dart';

void main() {
  const platformAdmin = CurrentUserPermissions(superAdmin: true);
  const branchAdmin = CurrentUserPermissions(
    permissions: {Permissions.systemAdmin},
    isAdmin: true,
  );

  group('organization setup route gating', () {
    test('platform admin can access setup wizard path', () {
      expect(
        canAccessPath('/platform/organizations/org-1/setup', platformAdmin),
        isTrue,
      );
    });

    test('branch admin without superAdmin is denied platform paths', () {
      expect(
        canAccessPath(PlatformDashboardRoute.path, branchAdmin),
        isFalse,
      );
      expect(
        canAccessPath('/platform/organizations/org-1/setup', branchAdmin),
        isFalse,
      );
    });

    test('setup path is permission-sensitive while permissions load', () {
      expect(
        isPermissionSensitivePath('/platform/organizations/org-1/setup'),
        isTrue,
      );
      expect(isPermissionSensitivePath(PlatformDashboardRoute.path), isTrue);
    });
  });
}
