import 'package:flutter_test/flutter_test.dart';
import 'package:hzn_gyms/src/features/users/domain/permission.dart';
import 'package:hzn_gyms/src/features/users/domain/user_role.dart';

void main() {
  group('UserRole', () {
    test('hasPermission and isAdmin', () {
      const role = UserRole(
        id: '1',
        name: 'Staff',
        permissions: [Permissions.membersView, Permissions.systemAdmin],
      );
      expect(role.hasPermission(Permissions.membersView), isTrue);
      expect(role.hasPermission(Permissions.membersDelete), isFalse);
      expect(role.isAdmin, isTrue);
      expect(role.permissionCountDisplay, '2 permissions');
      expect(
        const UserRole(
          id: 'x',
          name: 'One',
          permissions: ['a'],
        ).permissionCountDisplay,
        '1 permission',
      );
    });

    test('category helpers', () {
      final category = Permissions.allByCategory.keys.first;
      final allInCategory = Permissions.allByCategory[category]!;
      final role = UserRole(
        id: '2',
        name: 'Partial',
        permissions: [allInCategory.first],
      );
      expect(role.permissionCountInCategory(category), 1);
      expect(role.hasAllInCategory(category), allInCategory.length == 1);

      final full = UserRole(id: '3', name: 'Full', permissions: allInCategory);
      expect(full.hasAllInCategory(category), isTrue);
      expect(full.permissionObjects, hasLength(allInCategory.length));
      expect(full.permissionsByCategory.keys, isNotEmpty);
    });
  });

  group('Permissions', () {
    test('Sales category includes void permission', () {
      final salesPermissions = Permissions.allByCategory['Sales']!;
      expect(salesPermissions, contains(Permissions.salesVoid));
      expect(Permissions.getByKey(Permissions.salesVoid)?.category, 'Sales');
    });

    test('System category includes activityLog.view permission', () {
      final systemPermissions = Permissions.allByCategory['System']!;
      expect(systemPermissions, contains(Permissions.activityLogView));
      expect(
        Permissions.getByKey(Permissions.activityLogView)?.category,
        'System',
      );
    });
  });

  group('Permission', () {
    test('parses resource and action from key', () {
      const perm = Permission(
        key: 'members.view',
        name: 'View Members',
        category: 'Members',
      );
      expect(perm.id, 'members.view');
      expect(perm.resource, 'members');
      expect(perm.action, 'view');
    });
  });
}
