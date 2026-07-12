import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/outbox_attachments_table.dart';
import '../tables/outbox_table.dart';

part 'outbox_dao.g.dart';

/// Data access object for the generic outbox.
@DriftAccessor(tables: [OutboxEntries, OutboxAttachments])
class OutboxDao extends DatabaseAccessor<AppDatabase> with _$OutboxDaoMixin {
  OutboxDao(super.db);

  /// Enqueues a new outbox entry.
  Future<void> enqueue(OutboxEntriesCompanion entry) {
    return into(outboxEntries).insert(entry);
  }

  /// Replaces an existing pending member update for the same record.
  Future<void> replacePendingMemberUpdate({
    required String clientRecordId,
    required OutboxEntriesCompanion newEntry,
  }) async {
    await transaction(() async {
      final existing =
          await (select(outboxEntries)..where(
                (e) =>
                    e.clientRecordId.equals(clientRecordId) &
                    e.entityType.equals('member') &
                    e.operation.equals('update') &
                    e.status.equals('pending'),
              ))
              .get();

      for (final row in existing) {
        await (delete(
          outboxAttachments,
        )..where((a) => a.outboxId.equals(row.id))).go();
        await (delete(outboxEntries)..where((e) => e.id.equals(row.id))).go();
      }

      await into(outboxEntries).insert(newEntry);
    });
  }

  /// Saves a binary attachment for an outbox entry.
  Future<void> saveAttachment({
    required String outboxId,
    required String filename,
    required List<int> bytes,
  }) {
    return into(outboxAttachments).insertOnConflictUpdate(
      OutboxAttachmentsCompanion(
        outboxId: Value(outboxId),
        filename: Value(filename),
        bytes: Value(Uint8List.fromList(bytes)),
      ),
    );
  }

  /// Returns attachment bytes for an outbox entry, if any.
  Future<OutboxAttachmentRow?> getAttachment(String outboxId) {
    return (select(
      outboxAttachments,
    )..where((a) => a.outboxId.equals(outboxId))).getSingleOrNull();
  }

  /// Deletes attachment for an outbox entry.
  Future<void> deleteAttachment(String outboxId) {
    return (delete(
      outboxAttachments,
    )..where((a) => a.outboxId.equals(outboxId))).go();
  }

  /// Returns the next ready pending entry (FIFO, respects dependencies).
  Future<OutboxEntryRow?> getNextReady() async {
    final pending =
        await (select(outboxEntries)
              ..where((e) => e.status.equals('pending'))
              ..orderBy([(e) => OrderingTerm.asc(e.createdAt)]))
            .get();

    for (final entry in pending) {
      if (entry.dependsOnId == null) return entry;

      final parent = await (select(
        outboxEntries,
      )..where((e) => e.id.equals(entry.dependsOnId!))).getSingleOrNull();

      if (parent != null && parent.status == 'synced') return entry;
    }

    return null;
  }

  /// Marks an outbox entry status.
  Future<void> markStatus(
    String id, {
    required String status,
    String? lastError,
    int? attempts,
  }) {
    return (update(outboxEntries)..where((e) => e.id.equals(id))).write(
      OutboxEntriesCompanion(
        status: Value(status),
        lastError: lastError == null ? const Value.absent() : Value(lastError),
        attempts: attempts == null ? const Value.absent() : Value(attempts),
      ),
    );
  }

  /// Counts pending outbox entries.
  Future<int> countPending() async {
    return countInQueue();
  }

  /// Counts all non-synced queue entries (pending, failed, conflict).
  Future<int> countInQueue() async {
    final countExpr = outboxEntries.id.count();
    final query = selectOnly(outboxEntries)
      ..addColumns([countExpr])
      ..where(
        outboxEntries.status.equals('pending') |
            outboxEntries.status.equals('failed') |
            outboxEntries.status.equals('conflict'),
      );
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// Streams pending outbox count.
  Stream<int> watchPendingCount() => watchQueueCount();

  /// Streams count of all non-synced queue entries.
  Stream<int> watchQueueCount() {
    final countExpr = outboxEntries.id.count();
    final query = selectOnly(outboxEntries)
      ..addColumns([countExpr])
      ..where(
        outboxEntries.status.equals('pending') |
            outboxEntries.status.equals('failed') |
            outboxEntries.status.equals('conflict'),
      );
    return query.watchSingle().map((row) => row.read(countExpr) ?? 0);
  }

  /// Returns all non-synced entries for the pending list UI.
  Future<List<OutboxEntryRow>> getPendingAndFailed() {
    return (select(outboxEntries)
          ..where(
            (e) =>
                e.status.equals('pending') |
                e.status.equals('failed') |
                e.status.equals('conflict'),
          )
          ..orderBy([(e) => OrderingTerm.asc(e.createdAt)]))
        .get();
  }

  /// Returns an entry by id.
  Future<OutboxEntryRow?> getById(String id) {
    return (select(
      outboxEntries,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
  }
}
