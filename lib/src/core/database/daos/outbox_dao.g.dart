// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'outbox_dao.dart';

// ignore_for_file: type=lint
mixin _$OutboxDaoMixin on DatabaseAccessor<AppDatabase> {
  $OutboxEntriesTable get outboxEntries => attachedDatabase.outboxEntries;
  $OutboxAttachmentsTable get outboxAttachments =>
      attachedDatabase.outboxAttachments;
  OutboxDaoManager get managers => OutboxDaoManager(this);
}

class OutboxDaoManager {
  final _$OutboxDaoMixin _db;
  OutboxDaoManager(this._db);
  $$OutboxEntriesTableTableManager get outboxEntries =>
      $$OutboxEntriesTableTableManager(_db.attachedDatabase, _db.outboxEntries);
  $$OutboxAttachmentsTableTableManager get outboxAttachments =>
      $$OutboxAttachmentsTableTableManager(
        _db.attachedDatabase,
        _db.outboxAttachments,
      );
}
