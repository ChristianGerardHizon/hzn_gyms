import 'dart:async';

import 'package:pocketbase/pocketbase.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/organizations/presentation/controllers/current_organization_controller.dart';
import '../../features/organizations/presentation/controllers/organization_memberships_controller.dart';
import '../../features/users/data/repositories/user_role_repository.dart';
import '../../features/users/domain/user_role.dart';

part 'current_user_permissions.g.dart';

/// How often to silently re-fetch the signed-in user's role permissions.
const currentUserPermissionsPollInterval = Duration(minutes: 1);

/// Resolved permission set for the signed-in user.
class CurrentUserPermissions {
  const CurrentUserPermissions({
    this.permissions = const {},
    this.isAdmin = false,
    this.superAdmin = false,
  });

  static const empty = CurrentUserPermissions();

  final Set<String> permissions;
  final bool isAdmin;

  /// Platform operator flag from the auth user (`users.superAdmin`).
  final bool superAdmin;

  factory CurrentUserPermissions.fromRole(
    UserRole? role, {
    bool superAdmin = false,
  }) {
    if (role == null) {
      return CurrentUserPermissions(superAdmin: superAdmin);
    }
    final perms = role.permissions.toSet();
    return CurrentUserPermissions(
      permissions: perms,
      isAdmin: perms.contains(Permissions.systemAdmin),
      superAdmin: superAdmin,
    );
  }

  bool has(String permission) => isAdmin || permissions.contains(permission);

  bool get canManageUsers => has(Permissions.usersView);
  bool get canViewReports => has(Permissions.reportsView);
  bool get canViewSettings => has(Permissions.settingsView);

  /// Requires explicit [Permissions.salesVoid]; not granted by [isAdmin] alone.
  bool get canVoidSales => permissions.contains(Permissions.salesVoid);

  /// Requires explicit [Permissions.checkInsVoid]; not granted by [isAdmin] alone.
  bool get canVoidCheckIns => permissions.contains(Permissions.checkInsVoid);

  /// Cross-org platform access. Driven by [superAdmin] on the user record,
  /// not by role permissions (roles differ per organization).
  bool get canManageOrganizations => superAdmin;
  bool get canEditMemberships => has(Permissions.membershipsEdit);
  bool get canExcludeMembershipFromSales =>
      has(Permissions.membershipsExcludeFromSales);
  bool get canEditProductQuantity => has(Permissions.productsEditQuantity);
  bool get canAdjustInventory => has(Permissions.inventoryAdjust);
  bool get canManageSystem => has(Permissions.systemAdmin);
  bool get canViewActivityLog => has(Permissions.activityLogView);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CurrentUserPermissions) return false;
    return isAdmin == other.isAdmin &&
        superAdmin == other.superAdmin &&
        permissions.length == other.permissions.length &&
        permissions.containsAll(other.permissions);
  }

  @override
  int get hashCode => Object.hash(
    isAdmin,
    superAdmin,
    Object.hashAllUnordered(permissions),
  );
}

/// Loads and silently refreshes the current user's role permissions.
///
/// Prefer the active organization's membership role when present so the same
/// user can hold different roles per tenant. Platform [superAdmin] always
/// comes from the user record. KeepAlive poll/realtime still refresh the
/// resolved role permissions.
@Riverpod(keepAlive: true, name: 'currentUserPermissionsProvider')
class CurrentUserPermissionsController
    extends _$CurrentUserPermissionsController {
  /// Invalidates in-flight [refreshInBackground] calls after auth changes.
  int _refreshGeneration = 0;

  /// Coalesces overlapping background refreshes into a single in-flight fetch.
  Future<void>? _backgroundRefresh;

  UserRoleRepository get _repository => ref.read(userRoleRepositoryProvider);

  Future<String?> _resolveRoleId() async {
    final auth = ref.read(currentAuthProvider);
    if (auth == null) return null;
    final membership = await ref.read(
      currentOrganizationMembershipProvider.future,
    );
    if (membership != null && membership.roleId.isNotEmpty) {
      return membership.roleId;
    }
    return auth.user.roleId;
  }

  @override
  Future<CurrentUserPermissions> build() async {
    final auth = ref.watch(currentAuthProvider);
    if (auth == null) return CurrentUserPermissions.empty;

    final superAdmin = auth.user.superAdmin;
    ref.watch(currentOrganizationIdProvider);
    final roleId = await _resolveRoleId();
    if (roleId == null || roleId.isEmpty) {
      return CurrentUserPermissions(superAdmin: superAdmin);
    }

    var disposed = false;
    Timer? pollTimer;
    Timer? debounce;
    UnsubscribeFunc? unsubscribe;

    ref.onDispose(() {
      disposed = true;
      _refreshGeneration++;
      _backgroundRefresh = null;
      pollTimer?.cancel();
      debounce?.cancel();
      final unsub = unsubscribe;
      if (unsub != null) {
        unawaited(unsub());
      }
    });

    // Fetch first. Starting listeners before this finishes lets a background
    // refresh write AsyncData that Riverpod then overwrites with this return.
    final result = await _repository.fetchOne(roleId);
    final permissions = result.fold(
      (_) => CurrentUserPermissions(superAdmin: superAdmin),
      (role) => CurrentUserPermissions.fromRole(role, superAdmin: superAdmin),
    );

    if (disposed) return permissions;

    // Defer listeners until after Riverpod commits this build result.
    scheduleMicrotask(() {
      if (disposed || !ref.mounted) return;

      unawaited(
        _repository
            .subscribeOne(
              roleId,
              onEvent: (_) {
                if (disposed) return;
                debounce?.cancel();
                debounce = Timer(const Duration(milliseconds: 250), () {
                  if (!disposed) {
                    unawaited(refreshInBackground());
                  }
                });
              },
            )
            .then((unsub) {
              if (disposed) {
                unawaited(unsub());
              } else {
                unsubscribe = unsub;
              }
            }),
      );

      pollTimer = Timer.periodic(currentUserPermissionsPollInterval, (_) {
        if (!disposed) {
          unawaited(refreshInBackground());
        }
      });
    });

    return permissions;
  }

  /// Silently re-fetches role permissions without showing a loading state.
  Future<void> refreshInBackground() async {
    // Skip while the initial build is still loading — applying AsyncData here
    // would be overwritten when build() returns.
    if (!state.hasValue) return;

    final roleId = await _resolveRoleId();
    if (roleId == null || roleId.isEmpty) return;

    _backgroundRefresh ??= _refreshRolePermissions(roleId).whenComplete(
      () => _backgroundRefresh = null,
    );
    await _backgroundRefresh;
  }

  Future<void> _refreshRolePermissions(String roleId) async {
    final generation = _refreshGeneration;
    final result = await _repository.fetchOne(roleId);
    if (!ref.mounted || generation != _refreshGeneration) return;
    if (!state.hasValue) return;

    final superAdmin =
        ref.read(currentAuthProvider)?.user.superAdmin ?? false;
    result.fold(
      (_) {
        // Keep last known permissions on failure (offline / transient errors).
      },
      (role) {
        final next = CurrentUserPermissions.fromRole(
          role,
          superAdmin: superAdmin,
        );
        if (state.value == next) return;
        state = AsyncData(next);
      },
    );
  }
}

/// Whether the signed-in user may use the organization switcher.
///
/// Platform operators (`users.superAdmin`) can switch tenants even when
/// `users.organization` is set (active tenant for PB rules / gym data).
@Riverpod(keepAlive: true)
bool canUseOrganizationSwitcher(Ref ref) {
  final perms = ref.watch(currentUserPermissionsProvider).value;
  return perms?.canManageOrganizations ?? false;
}
