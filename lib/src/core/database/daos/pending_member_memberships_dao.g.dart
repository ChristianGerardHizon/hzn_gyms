// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_member_memberships_dao.dart';

// ignore_for_file: type=lint
mixin _$PendingMemberMembershipsDaoMixin on DatabaseAccessor<AppDatabase> {
  $PendingMemberMembershipsTable get pendingMemberMemberships =>
      attachedDatabase.pendingMemberMemberships;
  PendingMemberMembershipsDaoManager get managers =>
      PendingMemberMembershipsDaoManager(this);
}

class PendingMemberMembershipsDaoManager {
  final _$PendingMemberMembershipsDaoMixin _db;
  PendingMemberMembershipsDaoManager(this._db);
  $$PendingMemberMembershipsTableTableManager get pendingMemberMemberships =>
      $$PendingMemberMembershipsTableTableManager(
        _db.attachedDatabase,
        _db.pendingMemberMemberships,
      );
}
