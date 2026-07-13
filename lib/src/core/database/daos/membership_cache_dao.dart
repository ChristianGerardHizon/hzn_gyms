import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/membership_add_ons_table.dart';
import '../tables/membership_plans_table.dart';

part 'membership_cache_dao.g.dart';

/// DAO for cached membership plans and add-ons (offline read).
@DriftAccessor(tables: [MembershipPlans, MembershipAddOnsCache])
class MembershipCacheDao extends DatabaseAccessor<AppDatabase>
    with _$MembershipCacheDaoMixin {
  MembershipCacheDao(super.db);

  Future<void> replacePlans(List<MembershipPlansCompanion> plans) async {
    await transaction(() async {
      await delete(membershipPlans).go();
      if (plans.isNotEmpty) {
        await batch((b) => b.insertAll(membershipPlans, plans));
      }
    });
  }

  Future<void> replaceAddOns(
    List<MembershipAddOnsCacheCompanion> addOns,
  ) async {
    await transaction(() async {
      await delete(membershipAddOnsCache).go();
      if (addOns.isNotEmpty) {
        await batch((b) => b.insertAll(membershipAddOnsCache, addOns));
      }
    });
  }

  Future<void> upsertAddOns(List<MembershipAddOnsCacheCompanion> addOns) async {
    if (addOns.isEmpty) return;
    await batch((b) {
      b.insertAllOnConflictUpdate(membershipAddOnsCache, addOns);
    });
  }

  Future<List<MembershipPlanRow>> getPlans({String? branchId}) {
    // Branch filtering is done in the local data source via validBranches.
    final query = select(membershipPlans)
      ..orderBy([(p) => OrderingTerm.asc(p.name)]);
    return query.get();
  }

  Future<List<MembershipAddOnRow>> getAddOnsForPlan(String membershipId) {
    return (select(membershipAddOnsCache)
          ..where(
            (a) =>
                a.membershipId.equals(membershipId) & a.isActive.equals(true),
          )
          ..orderBy([(a) => OrderingTerm.asc(a.name)]))
        .get();
  }

  Future<bool> hasPlans() async {
    final countExpr = membershipPlans.id.count();
    final query = selectOnly(membershipPlans)..addColumns([countExpr]);
    final row = await query.getSingle();
    return (row.read(countExpr) ?? 0) > 0;
  }
}
