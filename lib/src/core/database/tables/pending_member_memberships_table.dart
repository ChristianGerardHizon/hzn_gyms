import 'package:drift/drift.dart';

/// Optimistic cache for offline membership renew/purchase UI.
@DataClassName('PendingMemberMembershipRow')
class PendingMemberMemberships extends Table {
  TextColumn get id => text()();
  TextColumn get memberId => text()();
  TextColumn get membershipId => text()();
  TextColumn get planName => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get status => text()();
  TextColumn get saleId => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
