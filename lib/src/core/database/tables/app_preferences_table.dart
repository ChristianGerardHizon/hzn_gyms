import 'package:drift/drift.dart';

/// Key-value store for durable app UI preferences (local Drift).
@DataClassName('AppPreferenceRow')
class AppPreferences extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
