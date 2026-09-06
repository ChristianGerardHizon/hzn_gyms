import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/core/navigation/app_nav_destination.dart';
import 'package:hzn_gyms/src/core/permissions/current_user_permissions.dart';
import 'package:hzn_gyms/src/features/users/domain/user_role.dart';

void main() {
  group('visibleAppNavDestinations', () {
    test(
      'Staff sees ops destinations plus Profile and System, not Org/Reports/Outbox',
      () {
        final staff = CurrentUserPermissions(
          permissions: {
            Permissions.membersView,
            Permissions.membershipsView,
            Permissions.checkInsView,
            Permissions.productsView,
            Permissions.salesView,
            Permissions.salesCreate,
            Permissions.settingsView,
          },
        );

        final ids = visibleAppNavDestinations(staff).map((d) => d.id).toList();

        expect(ids, contains(AppNavId.dashboard));
        expect(ids, contains(AppNavId.checkIn));
        expect(ids, isNot(contains(AppNavId.cashier)));
        expect(ids, contains(AppNavId.sales));
        expect(ids, contains(AppNavId.products));
        expect(ids, contains(AppNavId.members));
        expect(ids, contains(AppNavId.memberships));
        expect(ids, contains(AppNavId.profile));
        expect(ids, contains(AppNavId.system));
        expect(ids, isNot(contains(AppNavId.users)));
        expect(ids, isNot(contains(AppNavId.roles)));
        expect(ids, isNot(contains(AppNavId.branches)));
        expect(ids, isNot(contains(AppNavId.reports)));
        expect(ids, isNot(contains(AppNavId.outbox)));
      },
    );

    test('System nav is visible without settings.view', () {
      const minimal = CurrentUserPermissions();
      final ids = visibleAppNavDestinations(minimal).map((d) => d.id).toList();

      expect(ids, contains(AppNavId.dashboard));
      expect(ids, contains(AppNavId.system));
      expect(ids, contains(AppNavId.profile));
    });

    test('Admin with users.view sees Users instead of Profile', () {
      final admin = CurrentUserPermissions(
        permissions: {
          Permissions.usersView,
          Permissions.rolesView,
          Permissions.branchesView,
          Permissions.reportsView,
          Permissions.settingsView,
          Permissions.systemAdmin,
          Permissions.checkInsView,
          Permissions.salesView,
          Permissions.salesCreate,
          Permissions.productsView,
          Permissions.membersView,
          Permissions.membershipsView,
        },
        isAdmin: true,
      );

      final ids = visibleAppNavDestinations(admin).map((d) => d.id).toList();
      expect(ids, contains(AppNavId.users));
      expect(ids, contains(AppNavId.roles));
      expect(ids, contains(AppNavId.branches));
      expect(ids, isNot(contains(AppNavId.profile)));
      expect(ids, contains(AppNavId.reports));
      expect(ids, isNot(contains(AppNavId.outbox)));
    });
  });

  group('matchesRoutePath', () {
    test('does not treat /memberships as under /members', () {
      expect(matchesRoutePath('/members', '/members'), isTrue);
      expect(matchesRoutePath('/members/abc', '/members'), isTrue);
      expect(matchesRoutePath('/memberships', '/members'), isFalse);
      expect(matchesRoutePath('/memberships/abc', '/members'), isFalse);
      expect(matchesRoutePath('/memberships', '/memberships'), isTrue);
    });
  });

  group('canAccessPath', () {
    final staff = CurrentUserPermissions(
      permissions: {
        Permissions.membersView,
        Permissions.checkInsView,
        Permissions.salesView,
        Permissions.salesCreate,
        Permissions.settingsView,
      },
    );

    test('blocks users, roles, branches, and reports for staff', () {
      expect(canAccessPath('/users', staff), isFalse);
      expect(canAccessPath('/users/abc', staff), isFalse);
      expect(canAccessPath('/roles', staff), isFalse);
      expect(canAccessPath('/branches', staff), isFalse);
      expect(canAccessPath('/reports', staff), isFalse);
      expect(canAccessPath('/outbox', staff), isFalse);
    });

    test(
      'allows appearance and camera but not other system tabs for staff',
      () {
        expect(canAccessPath('/system', staff), isTrue);
        expect(canAccessPath('/system/appearance', staff), isTrue);
        expect(canAccessPath('/system/camera', staff), isTrue);
        expect(canAccessPath('/system/product-categories', staff), isFalse);
        expect(canAccessPath('/system/printers', staff), isFalse);
        expect(canAccessPath('/system/activity-log', staff), isFalse);
      },
    );

    test('allows appearance and camera without settings.view', () {
      const noSettings = CurrentUserPermissions(
        permissions: {Permissions.membersView},
      );
      expect(canAccessPath('/system', noSettings), isTrue);
      expect(canAccessPath('/system/appearance', noSettings), isTrue);
      expect(canAccessPath('/system/camera', noSettings), isTrue);
      expect(canAccessPath('/system/product-categories', noSettings), isFalse);
    });

    test('allows activity log for staff with activityLog.view', () {
      final withActivityLog = CurrentUserPermissions(
        permissions: {...staff.permissions, Permissions.activityLogView},
      );
      expect(canAccessPath('/system/activity-log', withActivityLog), isTrue);
      expect(
        canAccessPath('/system/activity-log/abc', withActivityLog),
        isTrue,
      );
      expect(
        canAccessPath('/system/product-categories', withActivityLog),
        isFalse,
      );

      const admin = CurrentUserPermissions(isAdmin: true);
      expect(canAccessPath('/system/activity-log', admin), isTrue);
      expect(canAccessPath('/system/activity-log/abc', admin), isTrue);
    });

    test('allows profile and core ops paths', () {
      expect(canAccessPath('/profile', staff), isTrue);
      expect(canAccessPath('/check-in', staff), isTrue);
      expect(canAccessPath('/check-in/records', staff), isTrue);
      expect(canAccessPath('/cashier', staff), isTrue);
      expect(canAccessPath('/sales', staff), isTrue);
      expect(canAccessPath('/members', staff), isTrue);
    });

    test('requires checkIns.view for check-in and nested records', () {
      final noCheckIns = CurrentUserPermissions(
        permissions: {
          Permissions.membersView,
          Permissions.salesView,
          Permissions.salesCreate,
          Permissions.settingsView,
        },
      );
      expect(canAccessPath('/check-in/records', noCheckIns), isFalse);
      expect(canAccessPath('/check-in', noCheckIns), isFalse);
    });

    test('treats /check-in/records as under /check-in', () {
      expect(matchesRoutePath('/check-in/records', '/check-in'), isTrue);
      expect(
        matchesRoutePath('/check-in/records', '/check-in/records'),
        isTrue,
      );
    });

    test('requires memberships.view for /memberships (not members.view)', () {
      expect(canAccessPath('/memberships', staff), isFalse);
      expect(canAccessPath('/memberships/abc', staff), isFalse);

      final withMemberships = CurrentUserPermissions(
        permissions: {...staff.permissions, Permissions.membershipsView},
      );
      expect(canAccessPath('/memberships', withMemberships), isTrue);
      expect(canAccessPath('/memberships/abc', withMemberships), isTrue);
    });
  });

  group('isPermissionSensitivePath', () {
    test('flags admin destinations that must wait for role load', () {
      expect(isPermissionSensitivePath('/users'), isTrue);
      expect(isPermissionSensitivePath('/roles'), isTrue);
      expect(isPermissionSensitivePath('/branches'), isTrue);
      expect(isPermissionSensitivePath('/reports'), isTrue);
      expect(isPermissionSensitivePath('/outbox'), isTrue);
      expect(isPermissionSensitivePath('/system/product-categories'), isTrue);
      expect(isPermissionSensitivePath('/system'), isFalse);
      expect(isPermissionSensitivePath('/system/appearance'), isFalse);
      expect(isPermissionSensitivePath('/system/camera'), isFalse);
      expect(isPermissionSensitivePath('/members'), isFalse);
      expect(isPermissionSensitivePath('/'), isFalse);
    });
  });

  group('CurrentUserPermissions', () {
    test(
      'isAdmin grants has() checks but not sales void without sales.void',
      () {
        const perms = CurrentUserPermissions(isAdmin: true);
        expect(perms.has(Permissions.salesVoid), isTrue);
        expect(perms.canVoidSales, isFalse);
        expect(perms.canEditProductQuantity, isTrue);
        expect(perms.canViewActivityLog, isTrue);
      },
    );

    test('canEditProductQuantity requires products.editQuantity or admin', () {
      const withPerm = CurrentUserPermissions(
        permissions: {Permissions.productsEditQuantity},
      );
      expect(withPerm.canEditProductQuantity, isTrue);

      const staff = CurrentUserPermissions(
        permissions: {Permissions.productsEdit},
      );
      expect(staff.canEditProductQuantity, isFalse);
    });

    test('canVoidSales requires explicit sales.void permission', () {
      const withVoid = CurrentUserPermissions(
        permissions: {Permissions.salesVoid},
      );
      expect(withVoid.canVoidSales, isTrue);

      const adminOnly = CurrentUserPermissions(
        permissions: {Permissions.systemAdmin},
        isAdmin: true,
      );
      expect(adminOnly.canVoidSales, isFalse);
    });

    test('activity log is granted to admins and activityLog.view', () {
      const viewer = CurrentUserPermissions(
        permissions: {Permissions.activityLogView},
      );
      expect(viewer.canViewActivityLog, isTrue);

      const staff = CurrentUserPermissions(
        permissions: {Permissions.membersView},
      );
      expect(staff.canViewActivityLog, isFalse);

      const admin = CurrentUserPermissions(isAdmin: true);
      expect(admin.canViewActivityLog, isTrue);
    });

    test('fromRole sets sales.void only when present', () {
      final withVoid = CurrentUserPermissions.fromRole(
        const UserRole(
          id: '1',
          name: 'Admin',
          permissions: [Permissions.salesVoid],
        ),
      );
      expect(withVoid.canVoidSales, isTrue);

      final withoutVoid = CurrentUserPermissions.fromRole(
        const UserRole(
          id: '2',
          name: 'Staff',
          permissions: [Permissions.salesView, Permissions.salesCreate],
        ),
      );
      expect(withoutVoid.canVoidSales, isFalse);
    });

    test('canEditMemberships follows memberships.edit', () {
      final withEdit = CurrentUserPermissions.fromRole(
        const UserRole(
          id: '1',
          name: 'Manager',
          permissions: [Permissions.membershipsEdit],
        ),
      );
      expect(withEdit.canEditMemberships, isTrue);

      final withoutEdit = CurrentUserPermissions.fromRole(
        const UserRole(
          id: '2',
          name: 'Staff',
          permissions: [Permissions.membershipsView],
        ),
      );
      expect(withoutEdit.canEditMemberships, isFalse);

      const admin = CurrentUserPermissions(isAdmin: true);
      expect(admin.canEditMemberships, isTrue);
    });

    test(
      'canExcludeMembershipFromSales follows memberships.excludeFromSales',
      () {
        final withPerm = CurrentUserPermissions.fromRole(
          const UserRole(
            id: '1',
            name: 'Manager',
            permissions: [Permissions.membershipsExcludeFromSales],
          ),
        );
        expect(withPerm.canExcludeMembershipFromSales, isTrue);

        final withoutPerm = CurrentUserPermissions.fromRole(
          const UserRole(
            id: '2',
            name: 'Staff',
            permissions: [Permissions.membershipsCreate],
          ),
        );
        expect(withoutPerm.canExcludeMembershipFromSales, isFalse);

        const admin = CurrentUserPermissions(isAdmin: true);
        expect(admin.canExcludeMembershipFromSales, isTrue);
      },
    );
  });

  group('selectedNavIndexForPath', () {
    test('maps nested paths by destination path', () {
      final dests = visibleAppNavDestinations(
        CurrentUserPermissions(
          permissions: {
            Permissions.membersView,
            Permissions.checkInsView,
            Permissions.salesView,
            Permissions.salesCreate,
            Permissions.productsView,
            Permissions.membershipsView,
            Permissions.settingsView,
          },
        ),
      );
      final membersIndex = dests.indexWhere((d) => d.id == AppNavId.members);
      expect(selectedNavIndexForPath('/members/abc', dests), membersIndex);

      final checkInIndex = dests.indexWhere((d) => d.id == AppNavId.checkIn);
      expect(selectedNavIndexForPath('/check-in/records', dests), checkInIndex);
    });
  });
}
