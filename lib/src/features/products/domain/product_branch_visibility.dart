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
