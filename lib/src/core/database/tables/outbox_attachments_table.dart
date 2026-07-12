import 'package:drift/drift.dart';

/// Binary attachments (e.g. member photos) linked to outbox entries.
@DataClassName('OutboxAttachmentRow')
class OutboxAttachments extends Table {
  TextColumn get outboxId => text()();
  TextColumn get filename => text()();
  BlobColumn get bytes => blob()();

  @override
  Set<Column<Object>> get primaryKey => {outboxId};
}
