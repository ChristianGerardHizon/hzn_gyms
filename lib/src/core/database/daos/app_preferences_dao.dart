import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/app_preferences_table.dart';

part 'app_preferences_dao.g.dart';

/// Data access for local key-value app preferences.
@DriftAccessor(tables: [AppPreferences])
class AppPreferencesDao extends DatabaseAccessor<AppDatabase>
    with _$AppPreferencesDaoMixin {
  AppPreferencesDao(super.db);

  /// Returns the stored value for [key], or null if missing.
  Future<String?> getValue(String key) async {
    final row = await (select(appPreferences)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  /// Inserts or updates [key] with [value].
  Future<void> setValue(String key, String value) {
    return into(appPreferences).insertOnConflictUpdate(
      AppPreferencesCompanion.insert(key: key, value: value),
    );
  }

  /// Writes multiple key-value pairs in one batch.
  Future<void> setValues(Map<String, String> entries) async {
    if (entries.isEmpty) return;
    await batch((batch) {
      batch.insertAllOnConflictUpdate(
        appPreferences,
        [
          for (final entry in entries.entries)
            AppPreferencesCompanion.insert(key: entry.key, value: entry.value),
        ],
      );
    });
  }
}
