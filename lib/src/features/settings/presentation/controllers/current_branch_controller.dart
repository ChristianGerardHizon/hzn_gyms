import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/storage/secure_storage_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../organizations/presentation/controllers/current_organization_controller.dart';
import '../../../users/presentation/controllers/user_provider.dart';
import '../../../users/presentation/controllers/user_role_provider.dart';
import '../../domain/branch.dart';
import 'branches_controller.dart';

part 'current_branch_controller.g.dart';

/// Storage key for persisting selected branch.
const _currentBranchStorageKey = 'CURRENT_BRANCH_ID';

/// Sentinel stored when admin selects "All branches".
const allBranchesSentinel = '__ALL__';

/// Resolved working-branch selection for the signed-in user.
class CurrentBranchSelection {
  const CurrentBranchSelection({
    this.branch,
    this.isAll = false,
  });

  /// Concrete branch when not viewing all.
  final Branch? branch;

  /// Admin "All branches" mode (org-scoped, not global).
  final bool isAll;

  /// Concrete branch id, or null when [isAll] / unset.
  String? get id => isAll ? null : branch?.id;
}

/// Controller for managing the current working branch.
///
/// - Admins: can switch to any branch in the current org or "All branches"
/// - Non-admins: can switch among allowed branches; locked if only one
@Riverpod(keepAlive: true)
class CurrentBranchController extends _$CurrentBranchController {
  @override
  Future<CurrentBranchSelection> build() async {
    final auth = ref.watch(currentAuthProvider);
    if (auth == null) {
      return const CurrentBranchSelection();
    }

    // Rebuild when the active organization changes (org switcher).
    ref.watch(currentOrganizationIdProvider);

    final orgBranches = await ref.watch(branchesControllerProvider.future);
    final orgBranchIds = orgBranches.map((b) => b.id).toSet();

    final defaultBranchId = auth.user.branch;
    final allowedIds = _resolveAllowedIds(
      auth.user.branch,
      auth.user.allowedBranches,
    );
    final isAdmin = await _checkIsAdmin();
    final persisted = await _loadPersistedBranch();

    if (isAdmin) {
      if (persisted == allBranchesSentinel) {
        return const CurrentBranchSelection(isAll: true);
      }
      final branchId = _pickValidBranchId(
        persisted: persisted,
        allowedIds: orgBranchIds.isEmpty ? null : orgBranchIds.toList(),
        defaultBranchId: defaultBranchId != null &&
                orgBranchIds.contains(defaultBranchId)
            ? defaultBranchId
            : (orgBranches.isEmpty ? null : orgBranches.first.id),
      );
      final branch =
          branchId != null ? await _fetchBranch(branchId) : null;
      if (branch != null) return CurrentBranchSelection(branch: branch);
      if (orgBranches.isNotEmpty) {
        return CurrentBranchSelection(branch: orgBranches.first);
      }
      return const CurrentBranchSelection(isAll: true);
    }

    final scopedAllowed = allowedIds
        .where((id) => orgBranchIds.isEmpty || orgBranchIds.contains(id))
        .toList();
    final branchId = _pickValidBranchId(
      persisted: persisted,
      allowedIds: scopedAllowed,
      defaultBranchId: defaultBranchId,
    );
    final branch =
        branchId != null ? await _fetchBranch(branchId) : null;
    return CurrentBranchSelection(branch: branch);
  }

  /// Whether the current user can open the branch switcher.
  Future<bool> canSwitchBranch() async {
    if (await _checkIsAdmin()) return true;
    final auth = ref.read(currentAuthProvider);
    if (auth == null) return false;
    final allowed = _resolveAllowedIds(
      auth.user.branch,
      auth.user.allowedBranches,
    );
    return allowed.length > 1;
  }

  /// Whether the user may select the "All branches" option (admins only).
  Future<bool> canViewAllBranches() async => await _checkIsAdmin();

  /// Branch IDs available in the switcher for the current user.
  Future<List<String>> switchableBranchIds() async {
    if (await _checkIsAdmin()) {
      final branches = await ref.read(branchesControllerProvider.future);
      return branches.map((b) => b.id).toList();
    }
    final auth = ref.read(currentAuthProvider);
    if (auth == null) return const [];
    return _resolveAllowedIds(auth.user.branch, auth.user.allowedBranches);
  }

  /// Switches to a concrete branch, or [allBranchesSentinel] for admin All.
  Future<void> switchBranch(String branchId) async {
    final isAdmin = await _checkIsAdmin();

    if (branchId == allBranchesSentinel) {
      if (!isAdmin) return;
      // Riverpod carries the previous value into this loading state, so branch
      // filters don't flash to "unfiltered / all" mid-switch.
      state = const AsyncLoading<CurrentBranchSelection>();
      await _persistBranch(allBranchesSentinel);
      state = const AsyncData(CurrentBranchSelection(isAll: true));
      return;
    }

    if (!isAdmin) {
      final auth = ref.read(currentAuthProvider);
      if (auth == null) return;
      final allowed = _resolveAllowedIds(
        auth.user.branch,
        auth.user.allowedBranches,
      );
      if (!allowed.contains(branchId)) return;
    }

    state = const AsyncLoading<CurrentBranchSelection>();
    await _persistBranch(branchId);

    final branch = await _fetchBranch(branchId);
    state = AsyncData(CurrentBranchSelection(branch: branch));
  }

  List<String> _resolveAllowedIds(
    String? defaultBranchId,
    List<String> allowed,
  ) {
    final ids = <String>{...allowed};
    if (defaultBranchId != null && defaultBranchId.isNotEmpty) {
      ids.add(defaultBranchId);
    }
    return ids.toList();
  }

  String? _pickValidBranchId({
    required String? persisted,
    required List<String>? allowedIds,
    required String? defaultBranchId,
  }) {
    if (persisted != null &&
        persisted.isNotEmpty &&
        persisted != allBranchesSentinel) {
      if (allowedIds == null || allowedIds.contains(persisted)) {
        return persisted;
      }
    }
    if (defaultBranchId != null &&
        defaultBranchId.isNotEmpty &&
        (allowedIds == null || allowedIds.contains(defaultBranchId))) {
      return defaultBranchId;
    }
    if (allowedIds != null && allowedIds.isNotEmpty) {
      return allowedIds.first;
    }
    return null;
  }

  Future<bool> _checkIsAdmin() async {
    final auth = ref.read(currentAuthProvider);
    if (auth == null) return false;

    final fullUser = await ref.read(userProvider(auth.user.id).future);
    if (fullUser == null ||
        fullUser.roleId == null ||
        fullUser.roleId!.isEmpty) {
      return false;
    }

    final userRole = await ref.read(userRoleProvider(fullUser.roleId!).future);
    if (userRole == null) return false;
    // Permission flag, with name fallback for roles missing seeded permissions.
    return userRole.isAdmin ||
        userRole.name.toLowerCase() == 'admin';
  }

  Future<Branch?> _fetchBranch(String branchId) async {
    final branches = await ref.read(branchesControllerProvider.future);
    return branches.cast<Branch?>().firstWhere(
          (b) => b?.id == branchId,
          orElse: () => null,
        );
  }

  Future<String?> _loadPersistedBranch() async {
    final storage = ref.read(secureStorageProvider);
    return await storage.read(key: _currentBranchStorageKey);
  }

  Future<void> _persistBranch(String branchId) async {
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: _currentBranchStorageKey, value: branchId);
  }
}

/// Whether admin is viewing all branches (no concrete branch filter).
@Riverpod(keepAlive: true)
bool viewingAllBranches(Ref ref) {
  return ref.watch(currentBranchControllerProvider).value?.isAll ?? false;
}

/// Convenience provider for current branch ID.
///
/// Returns `null` when admin has selected "All branches" or no branch is set.
@Riverpod(keepAlive: true)
String? currentBranchId(Ref ref) {
  return ref.watch(currentBranchControllerProvider).value?.id;
}

/// Convenience provider for branch filter string.
///
/// Returns `branch = "id" && isDeleted = false` for a concrete branch,
/// `branch.organization = "orgId" && isDeleted = false` when viewing All
/// branches in an org, or null while unset/loading / no org.
@Riverpod(keepAlive: true)
String? currentBranchFilter(Ref ref) {
  final selection = ref.watch(currentBranchControllerProvider).value;
  if (selection == null) return null;
  if (selection.isAll) {
    final orgId = ref.watch(currentOrganizationIdProvider);
    if (orgId == null || orgId.isEmpty) return null;
    return PBFilters.forBranchOrganization(orgId).build();
  }
  final branchId = selection.branch?.id;
  if (branchId == null) return null;
  return PBFilters.forBranch(branchId).build();
}

/// Branch ID to use when creating/updating records that require a branch.
///
/// Uses the current concrete branch when set. Returns null while "All" is
/// selected (writes must pick a specific branch). When no selection is set,
/// falls back to the authenticated user's default branch.
@Riverpod(keepAlive: true)
String? effectiveBranchIdForWrite(Ref ref) {
  final selection = ref.watch(currentBranchControllerProvider).value;
  if (selection == null) {
    final auth = ref.watch(currentAuthProvider);
    final defaultId = auth?.user.branch;
    if (defaultId != null && defaultId.isNotEmpty) return defaultId;
    return null;
  }
  if (selection.isAll) return null;

  final currentId = selection.branch?.id;
  if (currentId != null && currentId.isNotEmpty) return currentId;

  final auth = ref.watch(currentAuthProvider);
  final defaultId = auth?.user.branch;
  if (defaultId != null && defaultId.isNotEmpty) return defaultId;
  return null;
}
