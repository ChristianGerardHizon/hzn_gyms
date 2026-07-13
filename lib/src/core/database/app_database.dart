import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/app_preferences_dao.dart';
import 'daos/members_dao.dart';
import 'daos/membership_cache_dao.dart';
import 'daos/outbox_dao.dart';
import 'daos/pending_member_memberships_dao.dart';
import 'tables/app_preferences_table.dart';
import 'tables/members_table.dart';
import 'tables/membership_add_ons_table.dart';
import 'tables/membership_plans_table.dart';
import 'tables/outbox_attachments_table.dart';
import 'tables/outbox_table.dart';
import 'tables/pending_member_memberships_table.dart';

part 'app_database.g.dart';

/// Application-wide Drift database.
@DriftDatabase(
  tables: [
    Members,
    OutboxEntries,
    OutboxAttachments,
    PendingMemberMemberships,
    MembershipPlans,
    MembershipAddOnsCache,
    AppPreferences,
  ],
  daos: [
    MembersDao,
    OutboxDao,
    PendingMemberMembershipsDao,
    MembershipCacheDao,
    AppPreferencesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  AppDatabase.defaults()
    : super(
        driftDatabase(
          name: 'ebe_gym',
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          await migrator.createAll();
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await _addColumnIfMissing(
              migrator,
              table: members,
              column: members.branch,
            );
          }
          if (from < 3) {
            await _migrateToV3(migrator);
          }
          if (from < 4) {
            await _addColumnIfMissing(
              migrator,
              table: membershipPlans,
              column: membershipPlans.validBranchesJson,
            );
          }
          if (from < 5) {
            if (!await _tableExists(migrator, appPreferences.actualTableName)) {
              await migrator.createTable(appPreferences);
            }
          }
          if (from < 6) {
            await _addColumnIfMissing(
              migrator,
              table: membershipPlans,
              column: membershipPlans.memberNotRequired,
            );
          }
          if (from < 7) {
            await _addColumnIfMissing(
              migrator,
              table: membershipAddOnsCache,
              column: membershipAddOnsCache.durationDays,
            );
          }
        },
      );
}

/// Adds a column only when a prior partial migration did not already create it.
Future<void> _addColumnIfMissing(
  Migrator migrator, {
  required TableInfo<Table, Object?> table,
  required GeneratedColumn column,
}) async {
  if (await _columnExists(
    migrator,
    table.actualTableName,
    column.$name,
  )) {
    return;
  }
  await migrator.addColumn(table, column);
}

/// Idempotent v3 migration — safe to re-run after a partial failed upgrade.
Future<void> _migrateToV3(Migrator migrator) async {
  final db = migrator.database as AppDatabase;

  await _addColumnIfMissing(
    migrator,
    table: db.members,
    column: db.members.syncStatus,
  );
  await _addColumnIfMissing(
    migrator,
    table: db.members,
    column: db.members.localPhotoPath,
  );

  final tables = <TableInfo>[
    db.outboxEntries,
    db.outboxAttachments,
    db.pendingMemberMemberships,
    db.membershipPlans,
    db.membershipAddOnsCache,
  ];

  for (final table in tables) {
    if (!await _tableExists(migrator, table.actualTableName)) {
      await migrator.createTable(table);
    }
  }
}

Future<bool> _columnExists(
  Migrator migrator,
  String tableName,
  String columnName,
) async {
  final rows = await migrator.database
      .customSelect('PRAGMA table_info($tableName)')
      .get();
  return rows.any((row) => row.read<String>('name') == columnName);
}

Future<bool> _tableExists(Migrator migrator, String tableName) async {
  final rows = await migrator.database
      .customSelect(
        "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
        variables: [Variable.withString(tableName)],
      )
      .get();
  return rows.isNotEmpty;
}
