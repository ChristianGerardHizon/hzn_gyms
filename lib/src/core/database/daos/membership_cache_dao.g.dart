// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership_cache_dao.dart';

// ignore_for_file: type=lint
mixin _$MembershipCacheDaoMixin on DatabaseAccessor<AppDatabase> {
  $MembershipPlansTable get membershipPlans => attachedDatabase.membershipPlans;
  $MembershipAddOnsCacheTable get membershipAddOnsCache =>
      attachedDatabase.membershipAddOnsCache;
  MembershipCacheDaoManager get managers => MembershipCacheDaoManager(this);
}

class MembershipCacheDaoManager {
  final _$MembershipCacheDaoMixin _db;
  MembershipCacheDaoManager(this._db);
  $$MembershipPlansTableTableManager get membershipPlans =>
      $$MembershipPlansTableTableManager(
        _db.attachedDatabase,
        _db.membershipPlans,
      );
  $$MembershipAddOnsCacheTableTableManager get membershipAddOnsCache =>
      $$MembershipAddOnsCacheTableTableManager(
        _db.attachedDatabase,
        _db.membershipAddOnsCache,
      );
}
