import 'package:flutter_test/flutter_test.dart';
import 'package:ebe_gym/src/core/navigation/app_nav_destination.dart';
import 'package:ebe_gym/src/core/permissions/current_user_permissions.dart';
import 'package:ebe_gym/src/features/users/domain/user_role.dart';

void main() {
  group('visibleAppNavDestinations', () {
    test('Staff sees ops destinations plus Profile and System, not Org/Reports/Outbox',
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

      final ids =
          visibleAppNavDestinations(staff).map((d) => d.id).toList();

      expect(ids, contains(AppNavId.dashboard));
      expect(ids, contains(AppNavId.checkIn));
      expect(ids, contains(AppNavId.cashier));
      expect(ids, contains(AppNavId.sales));
      expect(ids, contains(AppNavId.products));
      expect(ids, contains(AppNavId.members));
      expect(ids, contains(AppNavId.memberships));
      expect(ids, contains(AppNavId.profile));
      expect(ids, contains(AppNavId.system));
      expect(ids, isNot(contains(AppNavId.organization)));
      expect(ids, isNot(contains(AppNavId.reports)));
      expect(ids, isNot(contains(AppNavId.outbox)));
    });

    test('Admin with users.view sees Organization instead of Profile', () {
      final admin = CurrentUserPermissions(
        permissions: {
          Permissions.usersView,
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
      expect(ids, contains(AppNavId.organization));
      expect(ids, isNot(contains(AppNavId.profile)));
      expect(ids, contains(AppNavId.reports));
      expect(ids, contains(AppNavId.outbox));
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

    test('blocks organization and reports for staff', () {
      expect(canAccessPath('/organization', staff), isFalse);
      expect(canAccessPath('/organization/users', staff), isFalse);
      expect(canAccessPath('/reports', staff), isFalse);
      expect(canAccessPath('/outbox', staff), isFalse);
    });

    test('allows appearance but not other system tabs for staff', () {
      expect(canAccessPath('/system', staff), isTrue);
      expect(canAccessPath('/system/appearance', staff), isTrue);
      expect(canAccessPath('/system/product-categories', staff), isFalse);
      expect(canAccessPath('/system/printers', staff), isFalse);
    });

    test('allows profile and core ops paths', () {
      expect(canAccessPath('/profile', staff), isTrue);
      expect(canAccessPath('/check-in', staff), isTrue);
      expect(canAccessPath('/cashier', staff), isTrue);
      expect(canAccessPath('/sales', staff), isTrue);
      expect(canAccessPath('/members', staff), isTrue);
    });
  });

  group('CurrentUserPermissions', () {
    test('isAdmin grants all checks', () {
      const perms = CurrentUserPermissions(isAdmin: true);
      expect(perms.has(Permissions.salesVoid), isTrue);
      expect(perms.canVoidSales, isTrue);
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
      final membersIndex =
          dests.indexWhere((d) => d.id == AppNavId.members);
      expect(
        selectedNavIndexForPath('/members/abc', dests),
        membersIndex,
      );
    });
  });
}
