import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/pending_member_memberships_table.dart';

part 'pending_member_memberships_dao.g.dart';

/// DAO for optimistic pending member membership records.
@DriftAccessor(tables: [PendingMemberMemberships])
class PendingMemberMembershipsDao extends DatabaseAccessor<AppDatabase>
    with _$PendingMemberMembershipsDaoMixin {
  PendingMemberMembershipsDao(super.db);

  Future<void> upsert(PendingMemberMembershipsCompanion entry) {
    return into(pendingMemberMemberships).insertOnConflictUpdate(entry);
  }

  Future<List<PendingMemberMembershipRow>> getByMember(String memberId) {
    return (select(pendingMemberMemberships)
          ..where((p) => p.memberId.equals(memberId))
          ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
        .get();
  }

  Future<void> markSynced(String id) {
    return (update(
      pendingMemberMemberships,
    )..where((p) => p.id.equals(id))).write(
      const PendingMemberMembershipsCompanion(syncStatus: Value('synced')),
    );
  }

  Future<void> deleteById(String id) {
    return (delete(
      pendingMemberMemberships,
    )..where((p) => p.id.equals(id))).go();
  }

  Future<void> deleteSynced() {
    return (delete(
      pendingMemberMemberships,
    )..where((p) => p.syncStatus.equals('synced'))).go();
  }
}
