import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'member_active_branch_filter_controller.g.dart';

/// Selected branch for filtering the Members list to active members.
///
/// `null` means All (no branch filter — full member list).
@Riverpod(keepAlive: true)
class MemberActiveBranchFilter extends _$MemberActiveBranchFilter {
  @override
  String? build() => null;

  /// Sets the branch filter, or clears it when [branchId] is null.
  void setBranchId(String? branchId) {
    final normalized = branchId == null || branchId.isEmpty ? null : branchId;
    if (state == normalized) return;
    state = normalized;
  }

  /// Clears the filter (All branches).
  void clear() => setBranchId(null);
}
