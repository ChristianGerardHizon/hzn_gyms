import 'package:drift/drift.dart';

/// Local read cache for membership plans (offline renew).
@DataClassName('MembershipPlanRow')
class MembershipPlans extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get durationDays => integer()();
  RealColumn get price => real()();
  TextColumn get branchId => text()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get syncedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
