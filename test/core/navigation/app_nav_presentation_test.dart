import 'package:hzn_gyms/src/core/navigation/app_nav_destination.dart';
import 'package:hzn_gyms/src/core/navigation/app_nav_presentation.dart';
import 'package:hzn_gyms/src/core/permissions/current_user_permissions.dart';
import 'package:hzn_gyms/src/core/routing/routes/dashboard.routes.dart';
import 'package:hzn_gyms/src/core/routing/routes/members.routes.dart';
import 'package:hzn_gyms/src/core/routing/routes/memberships.routes.dart';
import 'package:hzn_gyms/src/features/users/domain/user_role.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('app_nav_presentation', () {
    const adminPerms = CurrentUserPermissions(
      permissions: {
        Permissions.checkInsView,
        Permissions.salesView,
        Permissions.productsView,
        Permissions.membersView,
        Permissions.membershipsView,
        Permissions.reportsView,
        Permissions.usersView,
        Permissions.rolesView,
        Permissions.branchesView,
      },
      isAdmin: true,
    );

    test('visibleShortcutIds preserves default order for permitted destinations',
        () {
      final destinations = visibleAppNavDestinations(adminPerms);
      final shortcuts = visibleShortcutIds(destinations);

      expect(
        shortcuts,
        [
          AppNavId.checkIn,
          AppNavId.members,
          AppNavId.sales,
          AppNavId.products,
        ],
      );
    });

    test('categoryDestinations excludes shortcuts from category flyouts', () {
      final destinations = visibleAppNavDestinations(adminPerms);
      const excluded = {AppNavId.checkIn, AppNavId.members, AppNavId.sales};

      final people = categoryDestinations(
        AppNavCategory.people,
        destinations,
        excluded,
      );

      expect(people.map((d) => d.id), [AppNavId.memberships]);
    });

    test('isNavDestinationSelected matches nested paths', () {
      const destinations = [
        AppNavDestination(id: AppNavId.dashboard, path: DashboardRoute.path),
        AppNavDestination(id: AppNavId.members, path: MembersRoute.path),
      ];

      expect(
        isNavDestinationSelected('/', AppNavId.dashboard, destinations),
        isTrue,
      );
      expect(
        isNavDestinationSelected('/members/abc', AppNavId.members, destinations),
        isTrue,
      );
      expect(
        isNavDestinationSelected('/memberships', AppNavId.members, destinations),
        isFalse,
      );
    });

    test('isNavCategorySelected is true when a category child is active', () {
      final destinations = visibleAppNavDestinations(adminPerms);
      const excluded = {AppNavId.checkIn, AppNavId.members, AppNavId.sales};

      expect(
        isNavCategorySelected(
          MembershipsRoute.path,
          AppNavCategory.people,
          destinations,
          excluded,
        ),
        isTrue,
      );
    });

    group('filterNavDestinationsByQuery', () {
      String labelFor(AppNavId id) {
        switch (id) {
          case AppNavId.dashboard:
            return 'Dashboard';
          case AppNavId.members:
            return 'Members';
          case AppNavId.memberships:
            return 'Memberships';
          case AppNavId.reports:
            return 'Reports';
          default:
            return id.name;
        }
      }

      const destinations = [
        AppNavDestination(id: AppNavId.dashboard, path: DashboardRoute.path),
        AppNavDestination(id: AppNavId.members, path: MembersRoute.path),
        AppNavDestination(
          id: AppNavId.memberships,
          path: MembershipsRoute.path,
        ),
        AppNavDestination(id: AppNavId.reports, path: '/reports'),
      ];

      test('empty or whitespace query returns empty list', () {
        expect(
          filterNavDestinationsByQuery(destinations, '', labelFor),
          isEmpty,
        );
        expect(
          filterNavDestinationsByQuery(destinations, '   ', labelFor),
          isEmpty,
        );
      });

      test('matches case-insensitively by label contains', () {
        final results = filterNavDestinationsByQuery(
          destinations,
          'MEM',
          labelFor,
        );

        expect(
          results.map((d) => d.id),
          [AppNavId.members, AppNavId.memberships],
        );
      });

      test('returns empty list when nothing matches', () {
        expect(
          filterNavDestinationsByQuery(destinations, 'xyz', labelFor),
          isEmpty,
        );
      });
    });
  });
}
