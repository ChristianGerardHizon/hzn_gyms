import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../domain/membership.dart';
import '../../domain/membership_add_on.dart';

part 'membership_cache_local_data_source.g.dart';

/// Local Drift cache for membership plans and add-ons.
class MembershipCacheLocalDataSource {
  MembershipCacheLocalDataSource(this._db);

  final AppDatabase _db;

  Future<void> replacePlans(List<Membership> plans) async {
    final now = DateTime.now();
    final companions = plans
        .map(
          (p) => MembershipPlansCompanion.insert(
            id: p.id,
            name: p.name,
            description: Value(p.description),
            durationDays: p.durationDays,
            price: p.price.toDouble(),
            branchId: p.branchId,
            validBranchesJson: Value(jsonEncode(p.validBranches)),
            isActive: Value(p.isActive),
            isFavorite: Value(p.isFavorite),
            syncedAt: now,
          ),
        )
        .toList();
    await _db.membershipCacheDao.replacePlans(companions);
  }

  Future<void> replaceAddOns(List<MembershipAddOn> addOns) async {
    final now = DateTime.now();
    final companions = addOns
        .map(
          (a) => MembershipAddOnsCacheCompanion.insert(
            id: a.id,
            membershipId: a.membershipId,
            name: a.name,
            description: Value(a.description),
            price: a.price.toDouble(),
            isActive: Value(a.isActive),
            syncedAt: now,
          ),
        )
        .toList();
    await _db.membershipCacheDao.replaceAddOns(companions);
  }

  /// Returns cached plans. When [branchId] is set, only plans valid at that
  /// branch (or all-branch plans with empty validBranches) are returned.
  Future<List<Membership>> getPlans({String? branchId}) async {
    final rows = await _db.membershipCacheDao.getPlans();
    var plans = rows.map(_planRowToEntity).toList();
    if (branchId != null) {
      plans = plans.where((p) => p.isValidAtBranch(branchId)).toList();
    }
    return plans;
  }

  Future<void> upsertAddOns(List<MembershipAddOn> addOns) async {
    final now = DateTime.now();
    final companions = addOns
        .map(
          (a) => MembershipAddOnsCacheCompanion.insert(
            id: a.id,
            membershipId: a.membershipId,
            name: a.name,
            description: Value(a.description),
            price: a.price.toDouble(),
            isActive: Value(a.isActive),
            syncedAt: now,
          ),
        )
        .toList();
    await _db.membershipCacheDao.upsertAddOns(companions);
  }

  Future<List<MembershipAddOn>> getAddOnsForPlan(String membershipId) async {
    final rows = await _db.membershipCacheDao.getAddOnsForPlan(membershipId);
    return rows.map(_addOnRowToEntity).toList();
  }

  Future<bool> hasPlans() => _db.membershipCacheDao.hasPlans();

  Membership _planRowToEntity(MembershipPlanRow row) {
    return Membership(
      id: row.id,
      name: row.name,
      description: row.description,
      durationDays: row.durationDays,
      price: row.price,
      branchId: row.branchId,
      validBranches: _decodeValidBranches(row.validBranchesJson),
      isActive: row.isActive,
      isFavorite: row.isFavorite,
    );
  }

  List<String> _decodeValidBranches(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is! List) return const [];
      return decoded.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    } catch (_) {
      return const [];
    }
  }

  MembershipAddOn _addOnRowToEntity(MembershipAddOnRow row) {
    return MembershipAddOn(
      id: row.id,
      membershipId: row.membershipId,
      name: row.name,
      description: row.description,
      price: row.price,
      isActive: row.isActive,
    );
  }
}

@Riverpod(keepAlive: true)
MembershipCacheLocalDataSource membershipCacheLocalDataSource(Ref ref) {
  return MembershipCacheLocalDataSource(ref.watch(appDatabaseProvider));
}
