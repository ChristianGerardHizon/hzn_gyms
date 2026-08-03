import '../../memberships/domain/member_membership.dart';
import '../../memberships/domain/membership_payment_lifecycle.dart';
import '../../pos/data/repositories/sales_repository.dart';
import '../../pos/domain/sale.dart';

/// Keeps memberships that are active and whose linked sale (if any) is paid.
Future<List<MemberMembership>> filterCheckInEligibleMemberships({
  required List<MemberMembership> memberships,
  required SalesRepository salesRepo,
}) async {
  if (memberships.isEmpty) return const [];

  final saleCache = <String, Sale?>{};
  final eligible = <MemberMembership>[];

  for (final membership in memberships) {
    final saleId = membership.saleId?.trim();
    if (saleId == null || saleId.isEmpty) {
      if (isMembershipEligibleForCheckIn(status: membership.status)) {
        eligible.add(membership);
      }
      continue;
    }

    if (!saleCache.containsKey(saleId)) {
      final result = await salesRepo.getSale(saleId);
      saleCache[saleId] = result.fold((_) => null, (sale) => sale);
    }
    final sale = saleCache[saleId];
    if (isMembershipEligibleForCheckIn(
      status: membership.status,
      saleId: saleId,
      saleIsPaid: sale?.isPaid,
      saleStatus: sale?.status,
    )) {
      eligible.add(membership);
    }
  }

  return eligible;
}
