import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

import 'permission.dart';

part 'user_role.mapper.dart';

/// UserRole domain model.
///
/// Role definitions with permissions for access control.
/// Permissions are stored as a JSON array of permission keys in PocketBase.
@MappableClass()
class UserRole with UserRoleMappable {
  const UserRole({
    required this.id,
    required this.name,
    this.description,
    this.permissions = const [],
    this.isSystem = false,
    this.isDeleted = false,
    this.created,
    this.updated,
  });

  /// PocketBase record ID.
  final String id;

  /// Role name (e.g., "Admin", "Gym Manager", "Staff").
  final String name;

  /// Role description.
  final String? description;

  /// List of permission keys (stored as JSON array in PocketBase).
  final List<String> permissions;

  /// Whether this is a system-defined role (cannot be deleted).
  final bool isSystem;

  /// Soft delete flag.
  final bool isDeleted;

  /// Creation timestamp.
  final DateTime? created;

  /// Last update timestamp.
  final DateTime? updated;

  /// Check if role has a specific permission.
  bool hasPermission(String permission) => permissions.contains(permission);

  /// Check if role has admin permission.
  bool get isAdmin => permissions.contains('system.admin');

  /// Get permission count display.
  String get permissionCountDisplay =>
      '${permissions.length} permission${permissions.length == 1 ? '' : 's'}';

  /// Get the Permission objects for this role's permissions.
  List<Permission> get permissionObjects =>
      Permissions.getPermissions(permissions);

  /// Get permissions grouped by category.
  Map<String, List<Permission>> get permissionsByCategory {
    final map = <String, List<Permission>>{};
    for (final perm in permissionObjects) {
      map.putIfAbsent(perm.category, () => []).add(perm);
    }
    return map;
  }

  /// Check if role has all permissions in a category.
  bool hasAllInCategory(String category) {
    final categoryPerms = Permissions.allByCategory[category] ?? [];
    return categoryPerms.every((p) => permissions.contains(p));
  }

  /// Get the count of permissions in a specific category.
  int permissionCountInCategory(String category) {
    final categoryPerms = Permissions.allByCategory[category] ?? [];
    return categoryPerms.where((p) => permissions.contains(p)).length;
  }
}

/// Permission keys used in the system.
abstract class Permissions {
  // Member permissions
  static const membersView = 'members.view';
  static const membersCreate = 'members.create';
  static const membersEdit = 'members.edit';
  static const membersDelete = 'members.delete';

  // Membership permissions
  static const membershipsView = 'memberships.view';
  static const membershipsCreate = 'memberships.create';
  static const membershipsEdit = 'memberships.edit';
  static const membershipsDelete = 'memberships.delete';

  // Check-in permissions
  static const checkInsView = 'checkIns.view';
  static const checkInsCreate = 'checkIns.create';

  // Member card permissions
  static const memberCardsView = 'memberCards.view';
  static const memberCardsCreate = 'memberCards.create';
  static const memberCardsEdit = 'memberCards.edit';
  static const memberCardsDelete = 'memberCards.delete';

  // Reports permissions
  static const reportsView = 'reports.view';

  // Products permissions
  static const productsView = 'products.view';
  static const productsCreate = 'products.create';
  static const productsEdit = 'products.edit';
  static const productsDelete = 'products.delete';

  // Inventory permissions
  static const inventoryView = 'inventory.view';
  static const inventoryAdjust = 'inventory.adjust';

  // Sales permissions
  static const salesView = 'sales.view';
  static const salesCreate = 'sales.create';
  static const salesVoid = 'sales.void';

  // Users permissions
  static const usersView = 'users.view';
  static const usersCreate = 'users.create';
  static const usersEdit = 'users.edit';
  static const usersDelete = 'users.delete';

  // Roles permissions
  static const rolesView = 'roles.view';
  static const rolesCreate = 'roles.create';
  static const rolesEdit = 'roles.edit';
  static const rolesDelete = 'roles.delete';

  // Branches permissions
  static const branchesView = 'branches.view';
  static const branchesCreate = 'branches.create';
  static const branchesEdit = 'branches.edit';
  static const branchesDelete = 'branches.delete';

  // Settings permissions
  static const settingsView = 'settings.view';
  static const settingsEdit = 'settings.edit';

  // System permissions
  static const systemAdmin = 'system.admin';
  static const activityLogView = 'activityLog.view';

  /// All permissions grouped by category (keys only).
  static const Map<String, List<String>> allByCategory = {
    'Members': [membersView, membersCreate, membersEdit, membersDelete],
    'Memberships': [
      membershipsView,
      membershipsCreate,
      membershipsEdit,
      membershipsDelete,
    ],
    'Check-In': [checkInsView, checkInsCreate],
    'Member Cards': [
      memberCardsView,
      memberCardsCreate,
      memberCardsEdit,
      memberCardsDelete,
    ],
    'Reports': [reportsView],
    'Products': [productsView, productsCreate, productsEdit, productsDelete],
    'Inventory': [inventoryView, inventoryAdjust],
    'Sales': [salesView, salesCreate, salesVoid],
    'Users': [usersView, usersCreate, usersEdit, usersDelete],
    'Roles': [rolesView, rolesCreate, rolesEdit, rolesDelete],
    'Branches': [branchesView, branchesCreate, branchesEdit, branchesDelete],
    'Settings': [settingsView, settingsEdit],
    'System': [systemAdmin, activityLogView],
  };

  /// All permissions with full metadata.
  static final List<Permission> all = _buildPermissionList();

  /// Permissions grouped by category as Permission objects.
  static final Map<String, List<Permission>> allPermissionsByCategory =
      _buildPermissionsByCategory();

  /// Get a Permission by its key.
  static Permission? getByKey(String key) {
    try {
      return all.firstWhere((p) => p.key == key);
    } catch (_) {
      return null;
    }
  }

  /// Get all Permission objects for a list of keys.
  static List<Permission> getPermissions(List<String> keys) {
    return keys.map(getByKey).whereType<Permission>().toList();
  }

  /// Get display name for a permission key.
  static String displayName(String permission) {
    // First try to get from Permission object
    final perm = getByKey(permission);
    if (perm != null) return perm.name;

    // Fallback to computed display name
    final parts = permission.split('.');
    if (parts.length != 2) return permission;
    final action = parts[1];
    return action[0].toUpperCase() + action.substring(1);
  }

  /// Private: Build the full permission list with metadata.
  static List<Permission> _buildPermissionList() {
    return [
      // Members
      const Permission(
        key: membersView,
        name: 'View Members',
        category: 'Members',
        description: 'View member profiles and basic information',
        icon: Icons.visibility,
      ),
      const Permission(
        key: membersCreate,
        name: 'Create Members',
        category: 'Members',
        description: 'Register new gym members',
        icon: Icons.add,
      ),
      const Permission(
        key: membersEdit,
        name: 'Edit Members',
        category: 'Members',
        description: 'Modify existing member information',
        icon: Icons.edit,
      ),
      const Permission(
        key: membersDelete,
        name: 'Delete Members',
        category: 'Members',
        description: 'Remove member records (soft delete)',
        icon: Icons.delete,
      ),
      // Memberships
      const Permission(
        key: membershipsView,
        name: 'View Memberships',
        category: 'Memberships',
        description: 'View membership plans and subscriptions',
        icon: Icons.visibility,
      ),
      const Permission(
        key: membershipsCreate,
        name: 'Create Memberships',
        category: 'Memberships',
        description: 'Create membership plans and purchases',
        icon: Icons.add,
      ),
      const Permission(
        key: membershipsEdit,
        name: 'Edit Memberships',
        category: 'Memberships',
        description: 'Modify membership plans and subscriptions',
        icon: Icons.edit,
      ),
      const Permission(
        key: membershipsDelete,
        name: 'Delete Memberships',
        category: 'Memberships',
        description: 'Remove membership plans (soft delete)',
        icon: Icons.delete,
      ),
      // Check-In
      const Permission(
        key: checkInsView,
        name: 'View Check-Ins',
        category: 'Check-In',
        description: 'View check-in history and today\'s visits',
        icon: Icons.visibility,
      ),
      const Permission(
        key: checkInsCreate,
        name: 'Create Check-Ins',
        category: 'Check-In',
        description: 'Process member check-ins',
        icon: Icons.add,
      ),
      // Member Cards
      const Permission(
        key: memberCardsView,
        name: 'View Member Cards',
        category: 'Member Cards',
        description: 'View physical ID cards linked to members',
        icon: Icons.visibility,
      ),
      const Permission(
        key: memberCardsCreate,
        name: 'Create Member Cards',
        category: 'Member Cards',
        description: 'Issue new member ID cards',
        icon: Icons.add,
      ),
      const Permission(
        key: memberCardsEdit,
        name: 'Edit Member Cards',
        category: 'Member Cards',
        description: 'Update member card status and details',
        icon: Icons.edit,
      ),
      const Permission(
        key: memberCardsDelete,
        name: 'Delete Member Cards',
        category: 'Member Cards',
        description: 'Remove member cards (soft delete)',
        icon: Icons.delete,
      ),
      // Reports
      const Permission(
        key: reportsView,
        name: 'View Reports',
        category: 'Reports',
        description: 'View sales, inventory, and membership reports',
        icon: Icons.visibility,
      ),
      // Products
      const Permission(
        key: productsView,
        name: 'View Products',
        category: 'Products',
        description: 'View product catalog',
        icon: Icons.visibility,
      ),
      const Permission(
        key: productsCreate,
        name: 'Create Products',
        category: 'Products',
        description: 'Add new products to catalog',
        icon: Icons.add,
      ),
      const Permission(
        key: productsEdit,
        name: 'Edit Products',
        category: 'Products',
        description: 'Modify product information',
        icon: Icons.edit,
      ),
      const Permission(
        key: productsDelete,
        name: 'Delete Products',
        category: 'Products',
        description: 'Remove products from catalog',
        icon: Icons.delete,
      ),
      // Inventory
      const Permission(
        key: inventoryView,
        name: 'View Inventory',
        category: 'Inventory',
        description: 'View inventory levels and stock',
        icon: Icons.visibility,
      ),
      const Permission(
        key: inventoryAdjust,
        name: 'Adjust Inventory',
        category: 'Inventory',
        description: 'Make inventory adjustments',
        icon: Icons.tune,
      ),
      // Sales
      const Permission(
        key: salesView,
        name: 'View Sales',
        category: 'Sales',
        description: 'View sales history and reports',
        icon: Icons.visibility,
      ),
      const Permission(
        key: salesCreate,
        name: 'Create Sales',
        category: 'Sales',
        description: 'Process sales transactions',
        icon: Icons.add,
      ),
      const Permission(
        key: salesVoid,
        name: 'Void Sales',
        category: 'Sales',
        description: 'Void sales and payments (admin only)',
        icon: Icons.cancel,
      ),
      // Users
      const Permission(
        key: usersView,
        name: 'View Users',
        category: 'Users',
        description: 'View user accounts',
        icon: Icons.visibility,
      ),
      const Permission(
        key: usersCreate,
        name: 'Create Users',
        category: 'Users',
        description: 'Create new user accounts',
        icon: Icons.person_add,
      ),
      const Permission(
        key: usersEdit,
        name: 'Edit Users',
        category: 'Users',
        description: 'Modify user account details',
        icon: Icons.edit,
      ),
      const Permission(
        key: usersDelete,
        name: 'Delete Users',
        category: 'Users',
        description: 'Deactivate user accounts',
        icon: Icons.person_remove,
      ),
      // Roles
      const Permission(
        key: rolesView,
        name: 'View Roles',
        category: 'Roles',
        description: 'View role definitions',
        icon: Icons.visibility,
      ),
      const Permission(
        key: rolesCreate,
        name: 'Create Roles',
        category: 'Roles',
        description: 'Create new roles',
        icon: Icons.add,
      ),
      const Permission(
        key: rolesEdit,
        name: 'Edit Roles',
        category: 'Roles',
        description: 'Modify role permissions',
        icon: Icons.edit,
      ),
      const Permission(
        key: rolesDelete,
        name: 'Delete Roles',
        category: 'Roles',
        description: 'Remove roles (non-system only)',
        icon: Icons.delete,
      ),
      // Branches
      const Permission(
        key: branchesView,
        name: 'View Branches',
        category: 'Branches',
        description: 'View branch locations',
        icon: Icons.visibility,
      ),
      const Permission(
        key: branchesCreate,
        name: 'Create Branches',
        category: 'Branches',
        description: 'Add new branch locations',
        icon: Icons.add,
      ),
      const Permission(
        key: branchesEdit,
        name: 'Edit Branches',
        category: 'Branches',
        description: 'Modify branch information',
        icon: Icons.edit,
      ),
      const Permission(
        key: branchesDelete,
        name: 'Delete Branches',
        category: 'Branches',
        description: 'Remove branch locations',
        icon: Icons.delete,
      ),
      // Settings
      const Permission(
        key: settingsView,
        name: 'View Settings',
        category: 'Settings',
        description: 'View system settings',
        icon: Icons.visibility,
      ),
      const Permission(
        key: settingsEdit,
        name: 'Edit Settings',
        category: 'Settings',
        description: 'Modify system settings',
        icon: Icons.edit,
      ),
      // System
      const Permission(
        key: activityLogView,
        name: 'View Activity Log',
        category: 'System',
        description: 'View system-wide change history and audit trail',
        icon: Icons.history,
      ),
      const Permission(
        key: systemAdmin,
        name: 'System Admin',
        category: 'System',
        description: 'Full administrative access to all system features',
        icon: Icons.admin_panel_settings,
      ),
    ];
  }

  /// Private: Build permissions grouped by category.
  static Map<String, List<Permission>> _buildPermissionsByCategory() {
    final map = <String, List<Permission>>{};
    for (final permission in all) {
      map.putIfAbsent(permission.category, () => []).add(permission);
    }
    return map;
  }
}
