import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../settings/presentation/controllers/current_branch_controller.dart';
import '../../data/repositories/membership_repository.dart';
import '../../domain/membership.dart';

part 'membership_purchase_catalog_provider.g.dart';

/// Membership plans available in purchase / renew / new-member flows.
///
/// When [allBranches] is false, returns plans valid at the current working
/// branch (same as [MembershipsController]). When true, returns every plan
/// so staff can sell a plan whose [Membership.validBranches] targets another
/// branch; the sale still stamps the selling branch.
@riverpod
Future<List<Membership>> membershipPurchaseCatalog(
  Ref ref,
  bool allBranches,
) async {
  final repository = ref.watch(membershipRepositoryProvider);
  final branchId = allBranches ? null : ref.watch(currentBranchIdProvider);

  final result = await repository.fetchAll(branchId: branchId);

  return result.fold(
    (failure) => throw failure,
    (memberships) => memberships,
  );
}
