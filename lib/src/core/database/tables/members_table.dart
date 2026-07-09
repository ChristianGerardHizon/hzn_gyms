import 'package:drift/drift.dart';

/// Local cache table for gym members synced from PocketBase.
@DataClassName('MemberRow')
class Members extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get photoFile => text().nullable()();
  TextColumn get mobileNumber => text().nullable()();
  DateTimeColumn get dateOfBirth => dateTime().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get sex => text().nullable()();
  TextColumn get remarks => text().nullable()();
  TextColumn get addedBy => text().nullable()();
  TextColumn get rfidCardId => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get emergencyContact => text().nullable()();
  DateTimeColumn get created => dateTime().nullable()();
  DateTimeColumn get updated => dateTime().nullable()();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
