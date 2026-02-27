import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/member_membership_add_on_repository.dart';
import '../../domain/member_membership_add_on.dart';

part 'member_membership_add_ons_provider.g.dart';

/// Provider for fetching add-ons selected for a specific member membership.
@riverpod
Future<List<MemberMembershipAddOn>> memberMembershipAddOns(
  Ref ref,
  String memberMembershipId,
) async {
  final repository = ref.read(memberMembershipAddOnRepositoryProvider);
  final result =
      await repository.fetchByMemberMembership(memberMembershipId);

  return result.fold(
    (failure) => [],
    (addOns) => addOns,
  );
}
