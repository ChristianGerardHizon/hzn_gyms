import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/packages/pocketbase/pb_filter.dart';
import '../../../../core/packages/storage/secure_storage_provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../dashboard/presentation/controllers/inventory_alerts_controller.dart';
import '../../../dashboard/presentation/controllers/todays_sales_controller.dart';
import '../../../dashboard/presentation/controllers/top_selling_controller.dart';
import '../../../products/presentation/controllers/paginated_products_controller.dart';
import '../../../reports/presentation/controllers/inventory_report_controller.dart';
import '../../../reports/presentation/controllers/membership_report_controller.dart';
import '../../../reports/presentation/controllers/sales_report_controller.dart';
import '../../../sales/presentation/controllers/paginated_sales_controller.dart';
import '../../../users/presentation/controllers/user_provider.dart';
import '../../../users/presentation/controllers/user_role_provider.dart';
import '../../domain/branch.dart';
import 'branches_controller.dart';

part 'current_branch_controller.g.dart';

/// Storage key for persisting admin's selected branch.
const _currentBranchStorageKey = 'CURRENT_BRANCH_ID';

/// Controller for managing the current working branch.
///
/// - For admins: Allows switching between branches, persists selection
/// - For regular users: Locked to their assigned branch
@Riverpod(keepAlive: true)
class CurrentBranchController extends _$CurrentBranchController {
  @override
  Future<Branch?> build() async {
    final auth = ref.watch(currentAuthProvider);
    if (auth == null) return null;

    final userBranchId = auth.user.branch;
    final isAdmin = await _checkIsAdmin();

    if (isAdmin) {
      // Admin: Try to load persisted branch, fall back to user's branch
      final persistedBranchId = await _loadPersistedBranch();
      final branchId = persistedBranchId ?? userBranchId;
      return branchId != null ? await _fetchBranch(branchId) : null;
    } else {
      // Regular user: Locked to assigned branch
      return userBranchId != null ? await _fetchBranch(userBranchId) : null;
    }
  }

  /// Whether the current user can switch branches (admin only).
  Future<bool> canSwitchBranch() async => await _checkIsAdmin();

  /// Switches to a different branch (admin only).
  Future<void> switchBranch(String branchId) async {
    if (!await _checkIsAdmin()) return;

    state = const AsyncLoading();
    await _persistBranch(branchId);

    final branch = await _fetchBranch(branchId);
    state = AsyncData(branch);

    // Invalidate all branch-dependent providers
    _invalidateBranchDependentProviders();
  }

  Future<bool> _checkIsAdmin() async {
    final auth = ref.read(currentAuthProvider);
    if (auth == null) return false;

    // Get full user to access roleId
    final fullUser = await ref.read(userProvider(auth.user.id).future);
    if (fullUser == null || fullUser.roleId == null || fullUser.roleId!.isEmpty) {
      return false;
    }

    // Get user's role to check isAdmin
    final userRole = await ref.read(userRoleProvider(fullUser.roleId!).future);
    return userRole?.isAdmin ?? false;
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

  void _invalidateBranchDependentProviders() {
    // Invalidate all list controllers so they refetch with new branch filter
    ref.invalidate(paginatedProductsControllerProvider);
    ref.invalidate(paginatedSalesControllerProvider);

    // Invalidate dashboard providers
    ref.invalidate(todaySalesSummaryProvider);
    ref.invalidate(todaySalesProvider);
    ref.invalidate(inventoryAlertsSummaryProvider);
    ref.invalidate(topSellingProductsProvider);

    // Invalidate report providers
    ref.invalidate(salesReportProvider);
    ref.invalidate(inventoryReportProvider);
    ref.invalidate(membershipReportProvider);
  }
}

/// Convenience provider for current branch ID.
@Riverpod(keepAlive: true)
String? currentBranchId(Ref ref) {
  return ref.watch(currentBranchControllerProvider).value?.id;
}

/// Convenience provider for branch filter string.
///
/// Returns a filter string like `branch = "id"` or null if no branch selected.
@Riverpod(keepAlive: true)
String? currentBranchFilter(Ref ref) {
  final branchId = ref.watch(currentBranchIdProvider);
  if (branchId == null) return null;
  return PBFilters.forBranch(branchId).build();
}
