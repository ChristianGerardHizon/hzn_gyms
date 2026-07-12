import 'package:drift/drift.dart';

/// Generic outbox table for offline write operations.
@DataClassName('OutboxEntryRow')
class OutboxEntries extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  TextColumn get clientRecordId => text()();
  TextColumn get dependsOnId => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
