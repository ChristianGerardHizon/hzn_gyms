import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/users/domain/user_role.dart';
import '../../features/users/presentation/controllers/user_role_provider.dart';

part 'current_user_permissions.g.dart';

/// Resolved permission set for the signed-in user.
class CurrentUserPermissions {
  const CurrentUserPermissions({
    this.permissions = const {},
    this.isAdmin = false,
  });

  static const empty = CurrentUserPermissions();

  final Set<String> permissions;
  final bool isAdmin;

  factory CurrentUserPermissions.fromRole(UserRole? role) {
    if (role == null) return empty;
    final perms = role.permissions.toSet();
    return CurrentUserPermissions(
      permissions: perms,
      isAdmin: perms.contains(Permissions.systemAdmin),
    );
  }

  bool has(String permission) =>
      isAdmin || permissions.contains(permission);

  bool get canManageUsers => has(Permissions.usersView);
  bool get canViewReports => has(Permissions.reportsView);
  bool get canViewSettings => has(Permissions.settingsView);
  bool get canVoidSales => has(Permissions.salesVoid);
  bool get canEditMemberships => has(Permissions.membershipsEdit);
  bool get canManageSystem => has(Permissions.systemAdmin);
  bool get canViewActivityLog =>
      has(Permissions.activityLogView) || has(Permissions.systemAdmin);
}

/// Loads the current user's role permissions from PocketBase.
@Riverpod(keepAlive: true)
Future<CurrentUserPermissions> currentUserPermissions(Ref ref) async {
  final auth = ref.watch(currentAuthProvider);
  if (auth == null) return CurrentUserPermissions.empty;

  final roleId = auth.user.roleId;
  if (roleId == null || roleId.isEmpty) {
    return CurrentUserPermissions.empty;
  }

  final role = await ref.watch(userRoleProvider(roleId).future);
  return CurrentUserPermissions.fromRole(role);
}
