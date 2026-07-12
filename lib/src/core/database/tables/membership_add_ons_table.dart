import 'package:drift/drift.dart';

/// Local read cache for membership add-ons (offline renew).
@DataClassName('MembershipAddOnRow')
class MembershipAddOnsCache extends Table {
  TextColumn get id => text()();
  TextColumn get membershipId => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get price => real()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
