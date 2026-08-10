/// Whether a product should remain visible for the current branch selection.
///
/// When viewing all branches, or when no concrete branch is selected, the
/// product stays visible. Otherwise it must belong to [currentBranchId].
bool isProductVisibleForBranch({
  required String? productBranchId,
  required String? currentBranchId,
  required bool viewingAllBranches,
}) {
  if (viewingAllBranches || currentBranchId == null) return true;
  return productBranchId == currentBranchId;
}

/// Whether a deferred branch-mismatch dialog/redirect should still run.
///
/// Use after a post-frame callback so a branch switch that happened before the
/// callback fires can cancel a stale redirect.
bool shouldProceedWithBranchMismatchRedirect({
  required bool cancelled,
  required String? productBranchId,
  required String? currentBranchId,
  required bool viewingAllBranches,
}) {
  if (cancelled) return false;
  return !isProductVisibleForBranch(
    productBranchId: productBranchId,
    currentBranchId: currentBranchId,
    viewingAllBranches: viewingAllBranches,
  );
}
